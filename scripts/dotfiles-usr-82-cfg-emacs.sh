#!/usr/bin/env bash

export DEBUG='true'

set -e
[ $DEBUG = 'true' ] && set -x
THISDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
export EMACS_CONFIG_THISDIR="$(dirname ${THISDIR})"

source "${EMACS_CONFIG_THISDIR}/lib/dotfiles-utils.lib.sh"

dotfiles_config_paths_emacs

source ~/.dotfiles_config


export EMACS_LINK_PATH="$(dirname ${EMACS_D_PATH})"
export EMACS_CONFIG_PATH="$(dirname ${EMACS_LINK_PATH})"
export EMACS_D_PATH="${EMACS_D_PATH}"
export EMACS_D_SITE_LISP="${EMACS_D_PATH}/site-lisp"
export EMACS_D_LISP_LOCAL="${EMACS_D_PATH}/lisp-local"
export EMACS_D_THEMES="${EMACS_D_PATH}/themes"
export EMACS_SETUP_DONE_FLAG="${EMACS_CONFIG_PATH}/EMACS_SETUP_DONE.FLAG"

[ $DEBUG = 'true' ] && dotfiles_config_show_state

# check if setup done flag && exit
if [ -f "${EMACS_SETUP_DONE_FLAG}" ]; then
    echo "WARNING: Skipping ${BASH_SOURCE[0]} ... already ran"
    exit
fi

if [ ! -d "${EMACS_D_PATH}" ]; then
    dotfiles_emacs_install_purcells_config
    dotfiles_emacs_link_files
    dotfiles_emacs_install_jade_mode
    dotfiles_emacs_install_theme_solarized
    open /Applications/Emacs.app
else
    dotfiles_emacs_update_config
fi

echo "$(date) INFO: COMPLETED ${BASH_SOURCE[0]}"
