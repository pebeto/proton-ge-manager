#!/bin/bash
# Bash completion for proton-ge-manager

_proton_ge_manager_complete() {
    local cur prev words cword
    _init_completion || return
    
    case "$prev" in
        -i|--install|-r|--remove)
            # For install/remove, suggest version numbers
            # In a real implementation, this would list available versions
            COMPREPLY=($(compgen -W "9-19 9-20 10-0 10-1" -- "$cur"))
            return
            ;;
    esac
    
    # Main options
    COMPREPLY=($(compgen -W "-h --help -i --install -l --latest -L --list -s --status -r --remove -p --purge -I --interactive -f --force -y --yes" -- "$cur"))
}

complete -F _proton_ge_manager_complete proton-ge-manager.sh
