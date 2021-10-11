#!/usr/bin/env bash

[[ "${DEBUG}" != '' ]] || export DEBUG='false'

# Uncomment as needed
export DEBUG='true'

set -e
[[ "${DEBUG}" != 'true' ]] || set -x

THISDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

export EMACS_CONFIG_THISDIR="$(dirname ${THISDIR})"

export DOTFILES_CONFIG_EMACS='true'

export EMACS_ORG_SYNC_VIA="${EMACS_ORG_SYNC_VIA:-none}"

source "${EMACS_CONFIG_THISDIR}/lib/dotfiles-utils.lib.sh"

dotfiles_emacs_setup

echo "$(date) INFO: COMPLETED ${BASH_SOURCE[0]}"