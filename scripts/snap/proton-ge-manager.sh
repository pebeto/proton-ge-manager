#!/bin/sh

COMPATIBILITYTOOLS_DIR=~/snap/steam/common/.steam/root/compatibilitytools.d
RELEASE_URL="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton%s"
API_URL="https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest"

FORCE=0
ASSUME_YES=0

display_help () {
    echo "Usage: proton-ge-manager.sh [OPTION]"
    echo
    echo "Options:"
    echo "  -h, --help      Display this help message"
    echo "  -i, --install   Install specific Proton-GE version"
    echo "  -l, --latest    Install latest Proton-GE version"
    echo "  -L, --list      List installed Proton-GE versions"
    echo "  -r, --remove    Remove an installed Proton-GE version"
    echo "  -p, --purge     Remove all installed Proton-GE versions"
    echo "  -f, --force     Reinstall even if the version is already present"
    echo "  -y, --yes       Skip confirmation prompts"
    exit 0
}

install_proton_ge () {
    version=$1
    target_dir="$COMPATIBILITYTOOLS_DIR/GE-Proton$version"

    if [ -d "$target_dir" ] && [ "$FORCE" -eq 0 ]; then
        echo "Proton-GE $version is already installed. Use -f to reinstall."
        exit 0
    fi

    mkdir -p "$COMPATIBILITYTOOLS_DIR"

    base_url=$(printf "$RELEASE_URL" "$version")
    tarball_url="$base_url/GE-Proton$version.tar.gz"
    checksum_url="$base_url/GE-Proton$version.sha512sum"

    tarball=$(mktemp) || { echo "Error: mktemp failed"; exit 1; }
    trap 'rm -f "$tarball"' EXIT INT TERM

    echo "Downloading Proton-GE $version..."
    if ! curl --fail -L -o "$tarball" "$tarball_url"; then
        echo "Error: failed to download Proton-GE $version"
        exit 1
    fi

    echo "Verifying checksum..."
    expected=$(curl --fail -sL "$checksum_url" | awk '{print $1}')
    if [ -z "$expected" ]; then
        echo "Error: failed to fetch checksum"
        exit 1
    fi
    actual=$(sha512sum "$tarball" | awk '{print $1}')
    if [ "$expected" != "$actual" ]; then
        echo "Error: checksum mismatch"
        echo "  expected: $expected"
        echo "  actual:   $actual"
        exit 1
    fi

    if [ -d "$target_dir" ]; then
        rm -rf "$target_dir"
    fi

    echo "Extracting Proton-GE $version..."
    tar -xzf "$tarball" -C "$COMPATIBILITYTOOLS_DIR"
    echo "Proton-GE $version installed successfully!"
    exit 0
}

get_latest_version () {
    curl --fail -s "$API_URL" | grep tag_name | cut -d '"' -f 4 | grep -oP '[0-9]+-[0-9]+'
}

install_latest_proton_ge () {
    latest_version=$(get_latest_version)
    if [ -z "$latest_version" ]; then
        echo "Error: failed to determine latest version"
        exit 1
    fi
    echo "Latest Proton-GE version: $latest_version"
    install_proton_ge "$latest_version"
}

list_proton_ge () {
    if [ ! -d "$COMPATIBILITYTOOLS_DIR" ]; then
        echo "No Proton-GE versions installed."
        exit 0
    fi
    found=0
    for dir in "$COMPATIBILITYTOOLS_DIR"/GE-Proton*; do
        [ -d "$dir" ] || continue
        echo "${dir##*/GE-Proton}"
        found=1
    done
    if [ "$found" -eq 0 ]; then
        echo "No Proton-GE versions installed."
    fi
    exit 0
}

remove_proton_ge () {
    version=$1
    target_dir="$COMPATIBILITYTOOLS_DIR/GE-Proton$version"
    if [ ! -d "$target_dir" ]; then
        echo "Proton-GE $version is not installed."
        exit 1
    fi
    echo "Removing Proton-GE $version..."
    rm -rf "$target_dir"
    echo "Proton-GE $version removed successfully!"
    exit 0
}

purge_proton_ge () {
    if [ "$ASSUME_YES" -eq 0 ]; then
        printf "This will remove ALL installed Proton-GE versions. Continue? (y/N): "
        read -r answer
        case "$answer" in
            y|Y|yes|YES) ;;
            *) echo "Aborted."; exit 1 ;;
        esac
    fi
    echo "Removing all installed Proton-GE versions..."
    rm -rf "$COMPATIBILITYTOOLS_DIR"/GE-Proton*
    echo "All installed Proton-GE versions removed successfully!"
    exit 0
}

action=""
action_arg=""

while [ $# -gt 0 ]; do
    case $1 in
        -h|--help)
            display_help
            ;;
        -i|--install)
            if [ -z "$2" ]; then
                echo "Error: $1 requires a version argument"
                exit 1
            fi
            action="install"
            action_arg=$2
            shift 2
            ;;
        -l|--latest)
            action="latest"
            shift
            ;;
        -L|--list)
            action="list"
            shift
            ;;
        -r|--remove)
            if [ -z "$2" ]; then
                echo "Error: $1 requires a version argument"
                exit 1
            fi
            action="remove"
            action_arg=$2
            shift 2
            ;;
        -p|--purge)
            action="purge"
            shift
            ;;
        -f|--force)
            FORCE=1
            shift
            ;;
        -y|--yes)
            ASSUME_YES=1
            shift
            ;;
        *)
            echo "Error: Unknown option $1"
            display_help
            ;;
    esac
done

case "$action" in
    install) install_proton_ge "$action_arg" ;;
    latest)  install_latest_proton_ge ;;
    list)    list_proton_ge ;;
    remove)  remove_proton_ge "$action_arg" ;;
    purge)   purge_proton_ge ;;
    "")      display_help ;;
esac
