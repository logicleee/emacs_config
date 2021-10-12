#!/not/executable

#open -a "Terminal" ~/path/to/script.sh

[[ "${DEBUG}" != '' ]] || export DEBUG='false'

Ymd_HMS() { date +'%Y%m%d_%H%M%S'; }
bak_suffix=".bak_$(Ymd_HMS)"

dotfiles_setup() {
    _dotfiles_calc_and_export_paths
    _dotfiles_check_config_emacs

    [[ $DEBUG == 'true' ]] &&
        echo "${FUNCNAME[0]}" &&
        dotfiles_config_show_state

    _create_or_append_dotfiles_to_dotfiles_config
    _dotfiles_create_local_git_branch
    dotfiles_link_dotfiles
    dotfiles_copy_templates
    dotfiles_emacs_setup
    _dotfiles_update_ssh_folder_permissions
    dotfiles_zsh_install_or_update_ohmyzsh
    dotfiles_config_show_state
    _dotfiles_ssh_key_github_hints
    dotfiles_post_setup_message
}

dotfiles_emacs_setup() {
    dotfiles_config_paths_emacs

    source ~/.dotfiles_config
    _dotfiles_calc_and_export_paths_emacs

    if [[ "${DOTFILES_CONFIG_EMACS}" == 'true' ]]; then
        if [ ! -d "${EMACS_D_PATH}" ]; then
            dotfiles_emacs_install_purcells_config
            dotfiles_emacs_link_files
            dotfiles_emacs_install_jade_mode
            dotfiles_emacs_install_theme_solarized
            open /Applications/Emacs.app
        else
            dotfiles_emacs_update_config
        fi
    fi
}

dotfiles_link_all() {
    if dotfiles_is_cfged; then
        dotfiles_link_dotfiles
        if emacs_org_is_cfged; then
            _dotfiles_calc_and_export_paths_emacs
            dotfiles_emacs_link_files
        fi
    else
        echo "ERROR: ~/.dotfiles_config does not exist or is invalid! Run dotfiles_setup"
        return 1
    fi
}

_dotfiles_calc_and_export_paths() {
    [[ -e ~/.dotfiles_config ]] && source ~/.dotfiles_config || true

    # Ensure one of these is set before proceeding
    [[ "${DOTFILES_BASE_PATH}" != '' ]] ||
        [[ "${DOTFILES_SCRIPTS_THISDIR}" != '' ]] ||
        return 100

    if [[ "${DOTFILES_BASE_PATH}" == '' ]]; then
        export DOTFILES_BASE_PATH="$(dirname ${DOTFILES_SCRIPTS_THISDIR})"
        export DOTFILES_PATH="$DOTFILES_BASE_PATH"
    fi

    export PLATFORM="$(uname)"
    export DOTFILES_CP_USER_PATH="${DOTFILES_PATH}/copy/user"
    export DOTFILES_CP_USER_COMMON="${DOTFILES_CP_USER_PATH}/common"
    export DOTFILES_CP_USER_PLATFORM="${DOTFILES_CP_USER_PATH}/${PLATFORM}"
    export DOTFILES_CP_SYS_PATH="${DOTFILES_PATH}/copy/system"
    export DOTFILES_CP_SYS_COMMON="${DOTFILES_CP_SYS_PATH}/common"
    export DOTFILES_CP_SYS_PLATFORM="${DOTFILES_CP_SYS_PATH}/${PLATFORM}"
    export DOTFILES_LN_USER_PATH="${DOTFILES_PATH}/link/user"
    export DOTFILES_LN_USER_COMMON="${DOTFILES_LN_USER_PATH}/common"
    export DOTFILES_LN_USER_PLATFORM="${DOTFILES_LN_USER_PATH}/${PLATFORM}"
    export DOTFILES_LN_SYS_PATH="${DOTFILES_PATH}/link/system"
    export DOTFILES_LN_SYS_COMMON="${DOTFILES_LN_SYS_PATH}/common"
    export DOTFILES_LN_SYS_PLATFORM="${DOTFILES_LN_SYS_PATH}/${PLATFORM}"
    export DOTFILES_BASH_PROFILE_PATH="${DOTFILES_LN_USER_PATH}/.bash_profile"
    export DOTFILES_VIM_PATH="${DOTFILES_LN_USER_COMMON}/.vim"

    [[ "${DEBUG}" == 'true' ]] && dotfiles_config_show_state
}

dotfiles_link_dotfiles() {
    _dotfiles_create_dotfiles_paths
    _dotfiles_create_home_folders
    _dotfiles_link_files
}

_dotfiles_create_local_git_branch() {
    local _branch="${UID}.$(hostname)"
    cd "${DOTFILES_BASE_PATH}"
    git rev-parse --verify --quiet "${_branch}" >/dev/null ||
        git checkout -b "${_branch}"
    cd -
}

dotfiles_copy_templates() {
    cd "${DOTFILES_CP_USER_COMMON}"
    cp -R -n . "${HOME}/" || true
    cd -
}

dotfiles_link_emacs() {
    dotfiles_config_paths_emacs
    dotfiles_emacs_link_files
}

_dotfiles_check_config_emacs() {
    local _dfbp="${DOTFILES_BASE_PATH}/emacs_config"
    export DOTFILES_CONFIG_EMACS="${DOTFILES_CONFIG_EMACS:-true}"
    export EMACS_CONFIG_THISDIR="${EMACS_CONFIG_THISDIR:-${_dfbp}}"
    export EMACS_ORG_SYNC_VIA="${EMACS_ORG_SYNC_VIA:-none}"
}

dotfiles_zsh_install_or_update_ohmyzsh() {
    export CHSH='no'
    export RUNZSH='no'
    export KEEP_ZSHRC='yes'
    local URL='https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools'
    URL+='/install.sh'
    local zshrc="${DOTFILES_LN_USER_COMMON}/.zshrc"

    if [[ ! -d ~/.oh-my-zsh ]]; then
        sh -c "$(curl -fsSL $URL)" || true
        local xc=$?

        upgrade_oh_my_zsh || true
        [[ -e ~/.oh-my-zsh/custom/themes/powerlevel9k ]] ||
            git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k || true
        export ZSH_THEME="powerlevel9k/powerlevel9k"
        cd ~/.config/
        git clone https://github.com/powerline/fonts.git || true
        cd -
        cd ~/.config/fonts
        ./install.sh || true
        cd -

        _dotfiles_link_item "${zshrc}" "${HOME}/.zshrc"

        return $xc
    else
        cd ~/.oh-my-zsh
        git pull && cd -
        return $?
    fi
}

dotfiles_post_setup_message() {
    cat <<EOF

######################################################################
#          DOTFILES SETUP COMPLETE $(date)
######################################################################

-> Review the output above for any errors or warnings.

-> NOTE: The ~/.gitconfig is separated into several files:
$(grep "includeIf\|path" ~/.gitconfig)

-> ... and separate ssh keys for github can be configed in 
       ~/.ssh/config which can be used in conjunction with 
       git remote to separate home & work, i.e.:

    git remote set-url origin ssh://git@githome/<user>/<repo>.git

-> To view your current config:
    git config --get core.excludesfile '~/.gitignore_global'

    cd ~/some/path/from/above
    git config --get user.name
    git config --get user.email

-> To set/update your config, see below (or edit the files directly):
    git config --file=.gitconfig-personal --add user.name "personal username"
    git config --file=.gitconfig-personal --add user.email user@noreply.github.com

-> For zsh/powerline and themes:
    iTerm2 > Preferences > Profiles > Text > Change Font
    OR import the Default.json from:
    ~/dotfiles/local/iTerm/

-> A separate branch has been created for this user:
$(cd "$DOTFILES_BASE_PATH" && git status && cd -)

-> You can also now run the following commands to set user defaults 
for $(whoami):
    source ~/.lib/$(uname).setup.lib.sh
    default_user_setup

######################################################################

EOF
}

confirm() {
    local response
    local question=${1:-"Continue?"}
    while true; do
        read -p "$question (y/n/q): " response
        [[ $response =~ ^[Yy]$ ]] && return 0
        [[ $response =~ ^[Nn]$ ]] && return 1
        [[ $response =~ ^[Qq]$ ]] && exit 100
        echo "  Invalid response: $response"
    done
    return 2
}

_platform_is_linux() { [[ "$(uname)" == 'Linux' ]]; }

_platform_is_macOS() { [[ "$(uname)" == 'Darwin' ]]; }

_dotfiles_create_home_folders() {
    local dotfiles_folders=(
        "bin"
        "code"
        ".ssh"
    )

    for _d in ${dotfiles_folders[@]}; do
        local _dir="${HOME}/${_d}"
        [[ -d "${_dir}" ]] || mkdir -p "${_dir}"
    done
}

_dotfiles_create_dotfiles_paths() {
    local _dirs=(
        "${DOTFILES_CP_USER_COMMON}"
        "${DOTFILES_CP_USER_PLATFORM}"
        "${DOTFILES_CP_SYS_COMMON}"
        "${DOTFILES_CP_SYS_PLATFORM}"
        "${DOTFILES_LN_USER_COMMON}"
        "${DOTFILES_LN_USER_PLATFORM}"
        "${DOTFILES_LN_SYS_COMMON}"
        "${DOTFILES_LN_SYS_PLATFORM}"
    )

    for _d in ${_dirs[@]}; do
        [[ -d "${_d}" ]] || mkdir -p "${_d}"
    done

}

_dotfiles_ohmyzsh_set_theme() {
    local theme="${1:-powerlevel9k}"
    local regex='s/^#?(ZSH_THEME=).*/\1\"'
    regex+="$theme\/$theme"
    regex+='\"/'
    sed -E -e $regex -i .oldtheme.bak ~/.zshrc
}

_dotfiles_link_folders() {
    local dotfiles_folders=(
        ".lib"
    )

    for _d in ${dotfiles_folders[@]}; do
        local src="${DOTFILES_LN_USER_PATH}/${_d}"
        local dest="$HOME/${_d}"

        _dotfiles_link_item "$src" "$dest"
    done
}

_dotfiles_link_handle_base_files() {
    local _files=(
    )

    for _f in ${_files[@]}; do
        local src="${DOTFILES_LN_USER_PATH}/${_f}"
        #local dest="${HOME}/${_f/.sh/}"
        local dest="${HOME}/${_f}"

        [[ "${_f}" == '' ]] || _dotfiles_link_item "${src}" "${dest}"
    done
}

_dotfiles_link_handle_bash_profile() {
    if _platform_is_macOS; then
        _dotfiles_link_item "${DOTFILES_BASH_PROFILE_PATH}" "${HOME}/.bash_profile"
    fi

    if _platform_is_linux; then
        _dotfiles_link_item "${DOTFILES_BASH_PROFILE_PATH}" "${HOME}/.bashrc"
    fi
}

_dotfiles_link_files() {
    _dotfiles_link_folders
    _dotfiles_link_handle_base_files
    _dotfiles_link_handle_bash_profile
    _find_files_and_create_links "${DOTFILES_LN_USER_COMMON}"
    _find_files_and_create_links "${DOTFILES_LN_USER_PLATFORM}"
}

_find_files_and_create_links() {
    local _src
    cd "${1}"
    _src=$(pwd)
    #find . -type d -print0 | xargs -0 -n1 -I{} mkdir -pv "${HOME}/{}"
    #find . -type d -printf "%P\n" | awk 'NF' | xargs -n1 -I{} mkdir -p "${HOME}/{}"
    find . -type d |
        while IFS= read _f; do
            mkdir -pv "${HOME}/${_f}"
        done
    #find . -type f -print0 | xargs -0 -n1 -I{} ln -sfv "${_src}/{}" "${HOME}/{}"
    #find . -type f -printf "%P\n" | xargs -n1 -I{} ln -sf "${_src}/{}" "${HOME}/{}"
    find . -type f |
        while IFS= read _f; do
            _dotfiles_link_item "${_src}/${_f/\.\//}" "${HOME}/${_f}"
        done
    cd -
}

get_path() { printf "%s" "$(cd "$(dirname "${1}")" && pwd)"; }

log_info() {
    local _tags="${FUNCNAME[1]:-${funcstack[-1]:-undefined}} INFO:"
    printf "%s %s\n" "$_tags" "${1}"
    return 0
}

log_err() {
    local _tags="${FUNCNAME[1]:-${funcstack[-1]:-undefined}} ERROR:"
    printf "%s %s\n" "$_tags" "${1}"
    return 1
}

dotfiles_move_file_to_links() {
    [[ $# -eq 1 ]] || log_err "Too many arguments." || return 1
    [[ -L "${1}" ]] || log_err "Argument is a link already." || return 2
    [[ -f "${1}" ]] || log_err "Argument not a file." || return 3
    [[ "${DOTFILES_LN_USER_COMMON}" != '' ]] ||
        log_err "DOTFILES_LN_USER_COMMON not set to base destination path!" ||
        return 4

    local _filename="$(basename ${1})"
    local _srcpath="$(get_path ${1})"
    local _dest_base_path="${DOTFILES_LN_USER_COMMON}"
    local _src="${_srcpath}/${_filename}"
    local _dest="${_src/${HOME}/${_dest_base_path}}"
    local _destpath="$(dirname ${_dest})"

    [[ -f "${_src}" ]] || return 5
    cat <<E000f

######################################################################
  DOTFILES_LN_USER_COMMON is set to the path:

    ${DOTFILES_LN_USER_COMMON}
      

  The following commands will be executed:

    mkdir -p $_destpath

    mv -v $_src $_dest

    ln -sv $_dest $_src 
######################################################################

E000f

    printf "  => OK to proceed? (y/n): "
    read response
    [[ $response =~ ^[Yy]$ ]] || log_err "Aborting..." || return 1

    [[ -d "${_destpath}" ]] ||
        mkdir -p "${_destpath}"

    [[ -d "${_destpath}" ]] &&
        mv -pv "${_src}" "${_dest}" &&
        _dotfiles_link_item "${_dest}" "${_src}"
}

_dotfiles_update_ssh_folder_permissions() {
    chmod 700 ~/.ssh || true
    [[ -f ~/.ssh/id_rsa ]] && chmod 600 ~/.ssh/id_rsa || true
    [[ -f ~/.ssh/id_ecdsa ]] && chmod 600 ~/.ssh/id_ecdsa || true
}

_dotfiles_link_item() {
    if [[ "$#" -ne 2 ]]; then
        echo "ERROR: ${FUNCNAME[0]} expected 2 arguments but received $#"
        return 1
    fi
    local src="$1"
    local dest="$2"

    # test arg 1 exists or skip
    if [[ ! -e "$src" ]]; then
        echo "WARNING: Missing source file, skipping: $src"
        return 0
    fi

    # test arg 2 is link - remove
    _if_link_exists_remove_link "$dest"

    # test arg 2 exists - append name .bak_Ymd_HMS
    _if_exists_move_but_backup_item "$dest"

    # link to local file
    ln -sv "$src" "$dest"

}

_if_link_exists_remove_link() {
    if [[ "$#" -ne 1 ]]; then
        echo "ERROR: ${FUNCNAME[0]} expected 1 argument but received $#"
        return 1
    fi
    if [[ -L "$1" ]]; then rm -v "${1}"; fi
}

_if_exists_move_but_backup_item() {
    if [[ "$#" -ne 1 ]]; then
        echo "ERROR: ${FUNCNAME[0]} expected 1 argument but received $#"
        return 1
    fi

    local src="$1"
    local dest="${1}${bak_suffix:-.bak}"

    if [[ -e "${src}" ]]; then
        mv -v "${src}" "${dest}"
        return $?
    fi
    return 0
}

_dotfiles_ssh_key_github_hints() {
    cat <<EOF

######################################################################
# SSH KEY SETUP
######################################################################

# generate your key
  ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Open GitHub and sign in:
  open https://github.com/settings/keys

# use this to copy to clipboard for GitHub
  pbcopy < ~/.ssh/id_rsa.pub

# Start ssh-agent
  eval "\$(ssh-agent -s)"

# to add key to macOS KeyChain
  ssh-add -K ~/.ssh/id_rsa

# Update ~/.ssh/config

Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_rsa

######################################################################
######################################################################
EOF

}

################################################################################
#                                    FOR EMACS                                 #
################################################################################

emacs_org_is_cfged() { grep EMACS_ORG ~/.dotfiles_config >/dev/null 2>&1; }

dropbox_is_cfged() { grep DOTFILES_DROPBOX_PATH ~/.dotfiles_config >/dev/null 2>&1; }

_dropbox_path_exists() { [[ -d ~/Dropbox ]]; }

_dropbox_path_env_is_set() { [[ "${DOTFILES_DROPBOX_PATH}" != '' ]]; }

gdrive_is_cfged() { grep DOTFILES_GDRIVE_PATH ~/.dotfiles_config >/dev/null 2>&1; }

vim_is_cfged() { grep DOTFILES_VIM_PATH ~/.dotfiles_config >/dev/null 2>&1; }

dotfiles_is_cfged() {
    [[ -e ~/.dotfiles_config ]] &&
        grep DOTFILES_PATH ~/.dotfiles_config >/dev/null 2>&1
}

emacsd_path_is_ok() {
    [[ "${EMACS_CONFIG_THISDIR}" =~ "$(basename $HOME)" ]] &&
        [[ "${EMACS_CONFIG_THISDIR}/link/.emacs.d" == "${EMACS_D_PATH}" ]]
}

_append_vim_to_dotfiles_config() {
    local _default="${DOTFILES_LN_USER_COMMON}/.vim"
    if ! vim_is_cfged; then
        export DOTFILES_VIM_PATH="${DOTFILES_VIM_PATH:-${_default}}"
        echo "export DOTFILES_VIM_PATH=\"${DOTFILES_VIM_PATH}\"" >> \
            ~/.dotfiles_config
    fi
}

_append_dropbox_to_dotfiles_config() {
    local _default="${HOME}/Dropbox"
    if ! dropbox_is_cfged; then
        export DOTFILES_DROPBOX_PATH="${DOTFILES_DROPBOX_PATH:-${_default}}"
        echo "export DOTFILES_DROPBOX_PATH=${DOTFILES_DROPBOX_PATH}" >> \
            ~/.dotfiles_config
    fi
}

_append_gdrive_to_dotfiles_config() {
    local _default="${HOME}/Google Drive"
    if ! gdrive_is_cfged; then
        export DOTFILES_GDRIVE_PATH="${DOTFILES_GDRIVE_PATH:-${_default}}"
        echo "export DOTFILES_GDRIVE_PATH=\"${DOTFILES_GDRIVE_PATH}\"" >> \
            ~/.dotfiles_config
    fi
}

_create_or_append_dotfiles_to_dotfiles_config() {
    [[ ! -e ~/.dotfiles_config.tmp ]] ||
        rm ~/.dotfiles_config.tmp ||
        return 4

    if ! dotfiles_is_cfged; then
        if [[ -e ~/.dotfiles_config ]]; then
            mv ~/.dotfiles_config ~/.dotfiles_config.tmp || return 1
        fi
        cat <<E00F >>~/.dotfiles_config
# Use this file to point to your dotfiles folder, then run:
#  $ source ~/.lib/dotfiles-utils.lib.sh; dotfiles_link_all
export DOTFILES_BASE_PATH=${DOTFILES_BASE_PATH}
export DOTFILES_PATH=${DOTFILES_PATH}
E00F

        _append_vim_to_dotfiles_config
        _append_dropbox_to_dotfiles_config
        _append_gdrive_to_dotfiles_config

        if [[ -e ~/.dotfiles_config.tmp ]]; then
            cat ~/.dotfiles_config.tmp >>~/.dotfiles_config || return 3
            rm ~/.dotfiles_config.tmp || return 4
        fi

        return 0
    fi
}

_append_to_dotfiles_config_emacs() {
    echo "export EMACS_D_PATH=${EMACS_D_PATH}" >>~/.dotfiles_config
    echo "export EMACS_ORG_PATH=\"${EMACS_ORG_PATH}\"" >>~/.dotfiles_config
    echo "export EMACS_ORG_ARCHIVE_PATH=\"${EMACS_ORG_ARCHIVE_PATH}\"" >> \
        ~/.dotfiles_config
    echo "export EMACS_ORG_MEDIA_PATH=\"${EMACS_ORG_MEDIA_PATH}\"" >> \
        ~/.dotfiles_config
    echo "export EMACS_ORG_TEMPLATES_PATH=\"${EMACS_ORG_TEMPLATES_PATH}\"" >> \
        ~/.dotfiles_config

}

dotfiles_git_submodule_add_emacs_config() {
    [[ $DEBUG == 'true' ]] && echo "${FUNCNAME[0]}" && dotfiles_config_show_state
    cd "${DOTFILES_PATH}" &&
        [[ -d "emacs_config" ]] ||
        git submodule add https://github.com/logicleee/emacs_config.git
    cd -
}

dotfiles_emacs_install_purcells_config() {
    [[ $DEBUG == 'true' ]] && echo "${FUNCNAME[0]}" && dotfiles_config_show_state
    cd "${EMACS_CONFIG_REPO_PATH}/"
    [[ -d ".emacs.d" ]] ||
        git submodule add https://github.com/purcell/emacs.d.git .emacs.d
    cd -
}

dotfiles_emacs_install_jade_mode() {
    [[ $DEBUG == 'true' ]] && echo "${FUNCNAME[0]}" && dotfiles_config_show_state
    cd "${EMACS_D_SITE_LISP}"
    [[ -d "jade-mode" ]] ||
        git submodule add https://github.com/brianc/jade-mode.git
    cd -
}

dotfiles_emacs_install_theme_solarized() {
    [[ $DEBUG == 'true' ]] && echo "${FUNCNAME[0]}" && dotfiles_config_show_state
    cd "${EMACS_D_SITE_LISP}"
    [[ -d "emacs-color-theme-solarized" ]] ||
        git submodule add https://github.com/sellout/emacs-color-theme-solarized.git
    ln -svf "${EMACS_D_SITE_LISP}/emacs-color-theme-solarized/solarized-"* \
        "${EMACS_D_THEMES}/"
    cd -
}

dotfiles_emacs_update_config() {
    [[ $DEBUG == 'true' ]] && echo "${FUNCNAME[0]}" && dotfiles_config_show_state
    cd "${EMACS_CONFIG_REPO_PATH}/"
    git pull
    cd -
}

dotfiles_emacs_create_base_paths() {
    [[ $DEBUG == 'true' ]] && echo "${FUNCNAME[0]}" && dotfiles_config_show_state
    [[ -d "${EMACS_D_THEMES}" ]] || mkdir -p "${EMACS_D_THEMES}"
    [[ -d "${EMACS_ORG_PATH}" ]] || mkdir -p "${EMACS_ORG_PATH}"
    [[ -d "${EMACS_ORG_TEMPLATES_PATH}" ]] ||
        mkdir -p "${EMACS_ORG_TEMPLATES_PATH}"
    [[ -d "${EMACS_ORG_MEDIA_PATH}" ]] || mkdir -p "${EMACS_ORG_MEDIA_PATH}"
    [[ -d "${EMACS_ORG_ARCHIVE_PATH}" ]] || mkdir -p "${EMACS_ORG_ARCHIVE_PATH}"
}

dotfiles_emacs_link_files() {
    [[ $DEBUG == 'true' ]] && echo "${FUNCNAME[0]}" && dotfiles_config_show_state
    dotfiles_emacs_create_base_paths
    _dotfiles_link_item "${EMACS_D_PATH}" ~/.emacs.d
    _dotfiles_link_item "${EMACS_D_LISP_LOCAL}" "${EMACS_D_PATH}/lisp-local"
    _dotfiles_link_item "${EMACS_D_LISP_LOCAL}/init-local.el" \
        "$EMACS_D_PATH/lisp/init-local.el"
    [[ -d ~/org ]] ||
        _dotfiles_link_item "${EMACS_ORG_PATH}" "${HOME}/org"
    _dotfiles_link_item "${EMACS_ORG_TEMPLATES_PATH}" "${HOME}/org/templates"
    _dotfiles_link_item "${EMACS_ORG_MEDIA_PATH}" "${HOME}/org/media"
    _dotfiles_link_item "${EMACS_ORG_ARCHIVE_PATH}" "${HOME}/org/zarchive"
}

_create_dropbox_path() {
    if dropbox_is_cfged; then
        if ! _dropbox_path_exists; then
            mkdir -pv "${DOTFILES_DROPBOX_PATH}"
        fi
    fi
}

dotfiles_config_paths_emacs() {
    export CFG_EXISTS='false'
    export CFG_UPDATED='false'

    [[ -e ~/.dotfiles_config ]] && source ~/.dotfiles_config

    [[ -e ~/.dotfiles_config ]] && export CFG_EXISTS='true'

    if ! emacs_org_is_cfged; then
        case "$EMACS_ORG_SYNC_VIA" in
        dropbox)
            export EMACS_ORG_BASE_PATH="${DOTFILES_DROPBOX_PATH}"
            _append_dropbox_to_dotfiles_config
            break
            ;;
        gdrive)
            export EMACS_ORG_BASE_PATH="${DOTFILES_GDRIVE_PATH}"
            _append_gdrive_to_dotfiles_config
            break
            ;;
        none) ;;
        *)
            export EMACS_ORG_BASE_PATH="${EMACS_ORG_BASE_PATH:-${HOME}}"
            ;;
        esac

        export EMACS_ORG_PATH="${EMACS_ORG_BASE_PATH}/org"
        export EMACS_ORG_ARCHIVE_PATH="${EMACS_ORG_BASE_PATH}/org-zarchive"
        export EMACS_ORG_MEDIA_PATH="${EMACS_ORG_BASE_PATH}/org-media"

        if dotfiles_is_cfged && ! emacsd_path_is_ok; then
            # NOTE: This is the ONLY place that should reference DOTFILES_PATH
            echo "  EMACS_CONFIG_THISDIR: $EMACS_CONFIG_THISDIR"
            echo "          EMACS_D_PATH: ${EMACS_D_PATH}"
            echo "  ... Relocating this repo and starting over..."
            export EMACS_D_PATH="${DOTFILES_PATH}/emacs_config/link/.emacs.d"
            export EMACS_ORG_TEMPLATES_PATH="${DOTFILES_PATH}/emacs_config/link/org-capture-templates"
            _append_to_dotfiles_config_emacs
            dotfiles_git_submodule_add_emacs_config
            "${DOTFILES_PATH}"/emacs_config/scripts/dotfiles-usr-82-cfg-emacs.sh
            export CFG_UPDATED='true'
        else
            export EMACS_D_PATH="${EMACS_CONFIG_THISDIR}/link/.emacs.d"
            export EMACS_ORG_TEMPLATES_PATH="${EMACS_CONFIG_THISDIR}/link/org-capture-templates"
            _append_to_dotfiles_config_emacs
        fi
    fi
}

_dotfiles_calc_and_export_paths_emacs() {
    export EMACS_CONFIG_REPO_PATH="$(dirname ${EMACS_D_PATH})"
    export EMACS_CONFIG_PATH="$(dirname ${EMACS_CONFIG_REPO_PATH})"
    export EMACS_D_SITE_LISP="${EMACS_D_PATH}/site-lisp"
    export EMACS_D_LISP_LOCAL="${EMACS_CONFIG_REPO_PATH}/lisp-local"
    export EMACS_D_THEMES="${EMACS_D_PATH}/themes"
    export EMACS_SETUP_DONE_FLAG="${EMACS_CONFIG_PATH}/EMACS_SETUP_DONE.FLAG"
    [[ "${DEBUG}" == 'true' ]] && dotfiles_config_show_state
}

dotfiles_sync_emacs_scripts() {
    if [[ "${EMACS_CFG_DEV_PATH}" == '' ]] || [[ "${DOTFILES_DEV_PATH}" == '' ]]; then
        cat <<E000F
    ERROR: These paths must to point to base path for local repos:
        export EMACS_CFG_DEV_PATH="$EMACS_CFG_DEV_PATH"
        export DOTFILES_DEV_PATH="$DOTFILES_DEV_PATH"
E000F
        return 42
    fi
    cp -pv "${DOTFILES_DEV_PATH}/link/user/.lib/dotfiles-utils.lib.sh" \
        "${EMACS_CFG_DEV_PATH}/lib/" &&
        cp -pv "${DOTFILES_DEV_PATH}/scripts/dotfiles-usr-82-cfg-emacs.sh" \
            "${EMACS_CFG_DEV_PATH}/scripts"
    cd "${EMACS_CFG_DEV_PATH}" &&
        git checkout main &&
        git pull &&
        git status &&
        git commit -am'sync from dotfiles' &&
        git push
    cd -
}

dotfiles_config_show_state() {
    [[ -e ~/.dotfiles_config ]] ||
        echo "  ##### ~/.dotfiles_config DOES NOT EXIST #####"
    [[ -e ~/.dotfiles_config ]] &&
        echo "  ###### CONTENTS OF ~/.dotfiles_config #######"

    [[ -e ~/.dotfiles_config ]] && cat ~/.dotfiles_config

    cat <<E0F

    ################# ENVIRONMENT #################
$(set | grep "THISDIR\|EMACS_\|DOTFILES\|DEBUG\|PLATFORM\|ZSH" | sort)
    ###############################################

E0F
}

export SHELL_CFG_LOADED="${SHELL_CFG_LOADED}:${0}"
