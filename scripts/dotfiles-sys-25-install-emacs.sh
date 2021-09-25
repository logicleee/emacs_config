#!/usr/bin/env bash

YmdHMSpretty() { printf "%s" "$(date '+%Y-%m-%d_%H-%M-%S')"; }

timestamp_line() { printf '%s\n' "$(date +' ==> %Y-%m-%d %H:%M:%S ')$1"; }

logf() {
    local _tags="$(timestamp_line) $(basename ${BASH_SOURCE[2]:-undefined}):${FUNCNAME[1]:-undefined}"
    printf "%s %s\n" "$_tags" $1
    if [[ "${LOG_FILE}" != '' ]]; then
        printf "%s %s\n" "$_tags" $1 >>"${LOG_FILE}"
    fi
}

logs() {
    local _tags="$(basename ${BASH_SOURCE[2]:-undefined}):${FUNCNAME[1]:-undefined}"
    logger -t "$_tags" $1
}

install_emacs() {
    set -e
    if [[ "$(uname)" == 'Darwin' ]]; then
        logs "INFO Installing Emacs GUI on macOS"
        brew install --cask emacs
        return $?
    fi
    logf "ERROR Emacs install not implemented"
    return 1
}

install_emacs
