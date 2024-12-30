#!/bin/sh

COMPATIBILITYTOOLS_DIR=~/.var/app/com.valvesoftware.Steam/.steam/root/compatibilitytools.d

display_help () {
    echo "Usage: proton-ge-manager.sh [OPTION]"
    echo
    echo "Options:"
    echo "  -h, --help      Display this help message"
    echo "  -i, --install   Install specific Proton-GE version"
    echo "  -l, --latest    Install latest Proton-GE version"
    echo "  -r, --remove    Remove an installed Proton-GE version"
    echo "  -p, --purge     Remove all installed Proton-GE versions"
    exit 0
}

install_proton_ge () {
    version=$1
    url="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton%s/GE-Proton%s.tar.gz"
    formatted_url=$(printf $url $version $version)
    echo "Downloading Proton-GE $version..."
    curl --fail -L $formatted_url > /tmp/proton-ge.tar.gz
    echo "Extracting Proton-GE $version..."
    tar -xzf /tmp/proton-ge.tar.gz -C $COMPATIBILITYTOOLS_DIR
    rm -rf /tmp/proton-ge.tar.gz
    echo "Proton-GE $version installed successfully!"
    exit 0
}

get_latest_version () {
    echo $(curl --fail -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep tag_name | cut -d '"' -f 4 | grep -oP '[0-9]+-[0-9]+')
}

install_latest_proton_ge () {
    latest_version=$(get_latest_version)
    echo "Latest Proton-GE version: $latest_version"
    install_proton_ge $(get_latest_version)
}

remove_proton_ge () {
    version=$1
    echo "Removing Proton-GE $version..."
    rm -rf $COMPATIBILITYTOOLS_DIR/GE-Proton$version
    echo "Proton-GE $version removed successfully!"
    exit 0
}

purge_proton_ge () {
    echo "Removing all installed Proton-GE versions..."
    rm -rf $COMPATIBILITYTOOLS_DIR/GE-Proton*
    echo "All installed Proton-GE versions removed successfully!"
    exit 0
}

parse_args () {
    case $1 in
        -h|--help)
            display_help
            ;;
        -i|--install)
            install_proton_ge $2
            ;;
        -l|--latest)
            install_latest_proton_ge
            ;;
        -r|--remove)
            remove_proton_ge $2
            ;;
        -p|--purge)
            purge_proton_ge
            ;;
        *)
            echo "Error: Unknown option $1"
            display_help
            ;;
    esac
}

parse_args $1 $2
