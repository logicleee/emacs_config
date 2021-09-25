#!/usr/bin/env bash

Ymd_HMS() { date +'%Y%m%d_%H%M%S'; }
bak_suffix=".bak_$(Ymd_HMS)"

_if_link_exists_remove_it() {
    if [ "$#" -ne 1 ]; then
        echo "ERROR: ${FUNCNAME[0]} expected 1 arguments but received $#"
        return 1
    fi
    [ -L "$1" ] && rm -v "$1"
}

_if_exists_move_but_backup_item() {
    if [ "$#" -ne 1 ]; then
        echo "ERROR: ${FUNCNAME[0]} expected 1 arguments but received $#"
        return 1
    fi

    local src="$1"
    local dest="${1}${bak_suffix:-.bak}"

    if [ -e "$src" ]; then
        mv "$src" "$dest"
        return $?
    fi
    return 0
}

_dotfiles_link_item() {
    if [ "$#" -ne 2 ]; then
        echo "ERROR: ${FUNCNAME[0]} expected 2 arguments but received $#"
        return 1
    fi
    local src="$1"
    local dest="$2"

    # test arg 1 exists or skip
    if [ ! -e "$src" ]; then
        echo "WARNING: Missing source file, skipping: $src"
        return 0
    fi

    # test arg 2 is link - remove
    _if_link_exists_remove_it "$dest"

    # test arg 2 exists - append name .bak_Ymd_HMS
    _if_exists_move_but_backup_item "$dest"

    # link to local file
    ln -s "$src" "$dest"

}

################################################################################
#                                                                              #
#                           ADD BELOW TO DOTFILES LIB                          #
#                            THEN REPLACE THIS FILE                            #
#                                                                              #
################################################################################

emacs_org_is_cfged() { grep EMACS_ORG ~/.dotfiles_config >/dev/null 2>&1; }

dropbox_is_cfged() { grep DROPBOX_PATH ~/.dotfiles_config >/dev/null 2>&1; }

dropbox_path_exists() { [ -e ~/Dropbox/org ]; }

gdrive_is_cfged() { grep GOOGLE_DRIVE_PATH ~/.dotfiles_config >/dev/null 2>&1; }

vim_is_cfged() { grep VIM_PATH ~/.dotfiles_config >/dev/null 2>&1; }

dotfiles_is_cfged() {
    [ -e ~/.dotfiles_config ] &&
        grep DOTFILES_PATH ~/.dotfiles_config >/dev/null 2>&1
}

emacsd_path_is_ok() {
    [[ "${EMACS_CONFIG_THISDIR}" =~ "$(basename $HOME)" ]] &&
        [ "${EMACS_CONFIG_THISDIR}/link/.emacs.d" == "${EMACS_D_PATH}" ]
}

_append_vim_to_dotfiles_config() {
    echo "export VIM_PATH=${VIM_PATH}" >>~/.dotfiles_config
}

_append_dropbox_to_dotfiles_config() {
    echo "export DROPBOX_PATH=${DROPBOX_PATH}" >>~/.dotfiles_config
}

_append_to_dotfiles_config_gdrive() {
    echo "export GOOGLE_DRIVE_PATH=${GOOGLE_DRIVE_PATH}" >>~/.dotfiles_config
}

_create_or_append_dotfiles_to_dotfiles_config() {
    if ! dotfiles_is_cfged; then
        if [ -e ~/.dotfiles_config ]; then
            mv ~/.dotfiles_config ~/.dotfiles_config.tmp || return 1
        fi
        echo "export DOTFILES_PATH=${DOTFILES_PATH}" >>~/.dotfiles_config || return 2
        if [ -e ~/.dotfiles_config.tmp ]; then
            cat ~/.dotfiles_config.tmp >>~/.dotfiles_config || return 3
            rm ~/.dotfiles_config.tmp || return 4
        fi
        return 0
    fi
}

_append_to_dotfiles_config_emacs() {
    echo "export EMACS_ORG_PATH=${EMACS_ORG_PATH}" >>~/.dotfiles_config
    echo "export EMACS_ORG_ARCHIVE_PATH=${HOME}/org-zarchive" >>~/.dotfiles_config
    echo "export EMACS_ORG_MEDIA_PATH=${HOME}/org-media" >>~/.dotfiles_config

}

dotfiles_git_submodule_add_emacs_config() {
    [ $DEBUG = 'true' ] && echo "${FUNCNAME[0]}" && dotfiles_config_show_state
    cd "${DOTFILES_PATH}" &&
        git submodule add https://github.com/logicleee/emacs_config.git &&
        cd -
}

dotfiles_emacs_install_purcells_config() {
    [ $DEBUG = 'true' ] && echo "${FUNCNAME[0]}" && dotfiles_config_show_state
    cd "${EMACS_LINK_PATH}/"
    git submodule add https://github.com/purcell/emacs.d.git
    cd -
}

dotfiles_emacs_install_jade_mode() {
    [ $DEBUG = 'true' ] && echo "${FUNCNAME[0]}" && dotfiles_config_show_state
    cd "${EMACS_D_SITE_LISP}"
    git submodule add https://github.com/brianc/jade-mode.git
    cd -
}

dotfiles_emacs_install_theme_solarized() {
    [ $DEBUG = 'true' ] && echo "${FUNCNAME[0]}" && dotfiles_config_show_state
    cd "${EMACS_D_SITE_LISP}"
    git submodule add https://github.com/sellout/emacs-color-theme-solarized.git
    ln -s "${EMACS_D_SITE_LISP}/emacs-color-theme-solarized/solarized-"* \
        "${EMACS_D_THEMES}/"
    cd -
}

dotfiles_emacs_update_config() {
    [ $DEBUG = 'true' ] && echo "${FUNCNAME[0]}" && dotfiles_config_show_state
    cd "${EMACS_LINK_PATH}/"
    git pull
    cd -
}

dotfiles_emacs_link_files() {
    [ $DEBUG = 'true' ] && echo "${FUNCNAME[0]}" && dotfiles_config_show_state
    mkdir -p "${EMACS_D_THEMES}"
    _dotfiles_link_item "${EMACS_D_PATH}" ~/.emacs.d
    _dotfiles_link_item "${EMACS_D_LISP_LOCAL}" "${EMACS_D_PATH}/"
    _dotfiles_link_item "${EMACS_D_LISP_LOCAL}/init-local.el" \
        "$EMACS_D_PATH/lisp/init-local.el"
}

dotfiles_config_paths_emacs() {
    export CFG_EXISTS='false'
    export CFG_UPDATED='false'

    [ -e ~/.dotfiles_config ] && source ~/.dotfiles_config

    [ -e ~/.dotfiles_config ] && export CFG_EXISTS='true'

    if ! emacs_org_is_cfged; then
        if dropbox_path_exists; then
            if ! dropbox_is_cfged; then
                export DROPBOX_PATH=${HOME}/Dropbox
                _append_dropbox_to_dotfiles_config
            fi
            export EMACS_ORG_PATH="${DROPBOX_PATH}/org"
            export EMACS_ORG_ARCHIVE_PATH="${DROPBOX_PATH}/org-zarchive"
            export EMACS_ORG_MEDIA_PATH="${DROPBOX_PATH}/org-media"
        else
            export EMACS_ORG_PATH="${HOME}/org"
            export EMACS_ORG_ARCHIVE_PATH="${HOME}/org-zarchive"
            export EMACS_ORG_MEDIA_PATH="${HOME}/org-media"
        fi

        if dotfiles_is_cfged && ! emacsd_path_is_ok; then
            # NOTE: This is the ONLY place that should reference DOTFILES_PATH
            echo "  EMACS_CONFIG_THISDIR: $EMACS_CONFIG_THISDIR"
            echo "          EMACS_D_PATH: ${EMACS_D_PATH}"
            echo "  ... Relocating this repo and starting over..."
            export EMACS_D_PATH="${DOTFILES_PATH}/emacs_config/link/.emacs.d"
            export EMACS_ORG_TEMPLATES_PATH="${DOTFILES_PATH}/link/org-capture-templates"
            _append_to_dotfiles_config_emacs
            dotfiles_git_submodule_add_emacs_config
            "${DOTFILES_PATH}"/emacs_config/scripts/dotfiles-usr-82-cfg-emacs.sh
            exit $?
        fi

        export EMACS_D_PATH="${EMACS_CONFIG_THISDIR}/emacs_config/link/.emacs.d"
        export EMACS_ORG_TEMPLATES_PATH="${EMACS_CONFIG_THISDIR}/link/org-capture-templates"
        export CFG_UPDATED='true'
        _append_to_dotfiles_config_emacs
    fi
}

dotfiles_config_show_state() {
    [ -e ~/.dotfiles_config ] ||
        echo "  ##### ~/.dotfiles_config DOES NOT EXIST #####"
    [ -e ~/.dotfiles_config ] &&
        echo "  ###### CONTENTS OF ~/.dotfiles_config #######"

    [ -e ~/.dotfiles_config ] && cat ~/.dotfiles_config

    cat <<E0F

    ################# ENVIRONMENT #################
                      DEBUG: $DEBUG
              DOTFILES_PATH: $DOTFILES_PATH
                   VIM_PATH: $VIM_PATH
               EMACS_D_PATH: $EMACS_D_PATH
               DROPBOX_PATH: $DROPBOX_PATH
          GOOGLE_DRIVE_PATH: $GOOGLE_DRIVE_PATH

                    THISDIR: $THISDIR
       EMACS_CONFIG_THISDIR: $EMACS_CONFIG_THISDIR
            EMACS_LINK_PATH: $EMACS_LINK_PATH
          EMACS_CONFIG_PATH: $EMACS_CONFIG_PATH
          EMACS_D_SITE_LISP: $EMACS_D_SITE_LISP
         EMACS_D_LISP_LOCAL: $EMACS_D_LISP_LOCAL
             EMACS_D_THEMES: $EMACS_D_THEMES
      EMACS_SETUP_DONE_FLAG: $EMACS_SETUP_DONE_FLAG
    ###############################################

E0F
}
