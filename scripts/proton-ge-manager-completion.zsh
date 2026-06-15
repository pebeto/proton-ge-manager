#!/bin/zsh
# Zsh completion for proton-ge-manager

_proton_ge_manager_complete() {
    typeset -A opt_args
    local context state state_descr
    
    arguments=(
        '-h[Show help]' \
        '--help[Show help]' \
        '-i[Install specific version]' \
        '--install[Install specific version]:version:(9-19 9-20 10-0 10-1)' \
        '-l[Install latest version]' \
        '--latest[Install latest version]' \
        '-L[List installed versions]' \
        '--list[List installed versions]' \
        '-s[Show detailed status]' \
        '--status[Show detailed status]' \
        '-r[Remove version]' \
        '--remove[Remove version]:version:(9-19 9-20 10-0 10-1)' \
        '-p[Purge all versions]' \
        '--purge[Purge all versions]' \
        '-I[Interactive setup wizard]' \
        '--interactive[Interactive setup wizard]' \
        '-f[Force reinstall]' \
        '--force[Force reinstall]' \
        '-y[Skip confirmation]' \
        '--yes[Skip confirmation]'
    )
    
    _arguments ${arguments[@]}
}

compdef _proton_ge_manager_complete proton-ge-manager.sh
