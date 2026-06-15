#!/bin/sh
# Shared core logic for proton-ge-manager.
# Platform wrappers must set COMPATIBILITYTOOLS_DIR before sourcing this file.

RELEASE_URL="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton%s"
API_URL="https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest"

FORCE=0
ASSUME_YES=0

# Color codes for better output visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

validate_version () {
    version=$1
    case "$version" in
        ""|*[!0-9-]*)
            echo "${RED}Error: invalid version format: $version${NC}"
            exit 1
            ;;
    esac
}

install_proton_ge () {
    version=$1
    validate_version "$version"
    target_dir="$COMPATIBILITYTOOLS_DIR/GE-Proton$version"

    if [ -d "$target_dir" ] && [ "$FORCE" -eq 0 ]; then
        echo "${YELLOW}Proton-GE $version is already installed. Use -f to reinstall.${NC}"
        exit 0
    fi

    mkdir -p "$COMPATIBILITYTOOLS_DIR"

    base_url=$(printf "$RELEASE_URL" "$version")
    tarball_url="$base_url/GE-Proton$version.tar.gz"
    checksum_url="$base_url/GE-Proton$version.sha512sum"

    tarball=$(mktemp) || { echo "Error: mktemp failed"; exit 1; }
    trap 'rm -f "$tarball"' EXIT INT TERM

    echo "${BLUE}Downloading Proton-GE $version...${NC}"
    if ! curl --fail -L -# -o "$tarball" "$tarball_url"; then
        echo "${RED}Error: failed to download Proton-GE $version${NC}"
        exit 1
    fi

    echo "${BLUE}Verifying checksum...${NC}"
    expected=$(curl --fail -sL "$checksum_url" | awk '{print $1}')
    if [ -z "$expected" ]; then
        echo "${RED}Error: failed to fetch checksum${NC}"
        exit 1
    fi
    actual=$(sha512sum "$tarball" | awk '{print $1}')
    if [ "$expected" != "$actual" ]; then
        echo "${RED}Error: checksum mismatch${NC}"
        echo "  expected: $expected"
        echo "  actual:   $actual"
        exit 1
    fi

    if [ -d "$target_dir" ]; then
        rm -rf "$target_dir"
    fi

    echo "${BLUE}Extracting Proton-GE $version...${NC}"
    tar -xzf "$tarball" -C "$COMPATIBILITYTOOLS_DIR" 2>&1 | grep -v "^tar:" | grep -v "^" || true
    echo "${GREEN}Proton-GE $version installed successfully!${NC}"
    exit 0
}

get_latest_version () {
    curl --fail -s "$API_URL" | awk -F '"' '/tag_name/{print $4}' | sed -n 's/.*\([0-9]\+-[0-9]\+\).*/\1/p'
}

install_latest_proton_ge () {
    latest_version=$(get_latest_version)
    if [ -z "$latest_version" ]; then
        echo "${RED}Error: failed to determine latest version${NC}"
        exit 1
    fi
    echo "${BLUE}Latest Proton-GE version: $latest_version${NC}"
    install_proton_ge "$latest_version"
}

list_proton_ge () {
    if [ ! -d "$COMPATIBILITYTOOLS_DIR" ]; then
        echo "${YELLOW}No Proton-GE versions installed.${NC}"
        exit 0
    fi
    found=0
    for dir in "$COMPATIBILITYTOOLS_DIR"/GE-Proton*; do
        [ -d "$dir" ] || continue
        echo "${BLUE}${dir##*/GE-Proton}${NC}"
        found=1
    done
    if [ "$found" -eq 0 ]; then
        echo "${YELLOW}No Proton-GE versions installed.${NC}"
    fi
    exit 0
}

remove_proton_ge () {
    version=$1
    validate_version "$version"
    target_dir="$COMPATIBILITYTOOLS_DIR/GE-Proton$version"
    if [ ! -d "$target_dir" ]; then
        echo "${RED}Proton-GE $version is not installed.${NC}"
        exit 1
    fi
    echo "${BLUE}Removing Proton-GE $version...${NC}"
    rm -rf "$target_dir"
    echo "${GREEN}Proton-GE $version removed successfully!${NC}"
    exit 0
}

purge_proton_ge () {
    if [ "$ASSUME_YES" -eq 0 ]; then
        printf "This will remove ALL installed Proton-GE versions. Continue? (y/N): "
        read -r answer
        case "$answer" in
            y|Y|yes|YES) ;;
            *) echo "${YELLOW}Aborted.${NC}"; exit 1 ;;
        esac
    fi
    echo "${BLUE}Removing all installed Proton-GE versions...${NC}"
    rm -rf "$COMPATIBILITYTOOLS_DIR"/GE-Proton*
    echo "${GREEN}All installed Proton-GE versions removed successfully!${NC}"
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
            echo "${RED}Error: Unknown option $1${NC}"
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
