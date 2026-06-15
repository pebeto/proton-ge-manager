#!/bin/sh
# Shared core logic for proton-ge-manager.
# Platform wrappers must set COMPATIBILITYTOOLS_DIR before sourcing this file.

RELEASE_URL="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton%s"
API_URL="https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest"

FORCE=0
ASSUME_YES=0

# Color codes for better output visibility
# Enable colors by default if terminal supports them, disable if not
if [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ "$(tput colors)" -ge 8 ] 2>/dev/null; then
    RED=$(printf '\033[0;31m')
    GREEN=$(printf '\033[0;32m')
    YELLOW=$(printf '\033[1;33m')
    BLUE=$(printf '\033[0;34m')
    NC=$(printf '\033[0m') # No Color
else
    # No colors for terminals without color support
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

display_help () {
    echo "Usage: proton-ge-manager.sh [OPTION]"
    echo
    echo "Options:"
    echo "  -h, --help      Display this help message"
    echo "  -i, --install   Install specific Proton-GE version"
    echo "  -l, --latest    Install latest Proton-GE version"
    echo "  -L, --list      List installed Proton-GE versions"
    echo "  -s, --status    Show detailed status of installed versions"
    echo "  -r, --remove    Remove an installed Proton-GE version"
    echo "  -p, --purge     Remove all installed Proton-GE versions"
    echo "  -I, --interactive Interactive setup wizard"
    echo "  -f, --force     Reinstall even if the version is already present"
    echo "  -y, --yes       Skip confirmation prompts"
    exit 0
}

validate_version () {
    version=$1
    case "$version" in
        ""|*[!0-9-]*)
            echo "${RED}Error: invalid version format: $version${NC}"
            echo "${YELLOW}Please use format like '9-19' or '10-0'${NC}"
            exit 1
            ;;
    esac
}

verify_steam_path () {
    if [ ! -d "$COMPATIBILITYTOOLS_DIR" ]; then
        echo "${YELLOW}Steam compatibility tools directory not found at: ${NC}"
        echo "${BLUE}$COMPATIBILITYTOOLS_DIR${NC}"
        echo ""
        echo "${YELLOW}This may indicate:${NC}"
        echo "  - Steam is not installed"
        echo "  - Steam has not been launched yet"
        echo "  - You are using a different installation method"
        echo ""
        echo "${YELLOW}Please ensure Steam is installed and has been launched at least once.${NC}"
        echo "${YELLOW}If you are using a custom Steam installation, set COMPATIBILITYTOOLS_DIR before running this script.${NC}"
        exit 1
    fi
}

install_proton_ge () {
    version=$1
    validate_version "$version"
    verify_steam_path
    target_dir="$COMPATIBILITYTOOLS_DIR/GE-Proton$version"

    if [ -d "$target_dir" ] && [ "$FORCE" -eq 0 ]; then
        echo "${YELLOW}Proton-GE $version is already installed.${NC}"
        echo "${YELLOW}Use -f flag to force reinstallation.${NC}"
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
        echo "${YELLOW}Check your internet connection or try again later.${NC}"
        exit 1
    fi

    echo "${BLUE}Verifying checksum...${NC}"
    expected=$(curl --fail -sL "$checksum_url" | awk '{print $1}')
    if [ -z "$expected" ]; then
        echo "${RED}Error: failed to fetch checksum${NC}"
        echo "${YELLOW}This may indicate a network issue or GitHub API rate limiting.${NC}"
        exit 1
    fi
    actual=$(sha512sum "$tarball" | awk '{print $1}')
    if [ "$expected" != "$actual" ]; then
        echo "${RED}Error: checksum mismatch${NC}"
        echo "  expected: $expected"
        echo "  actual:   $actual"
        echo "${YELLOW}The downloaded file may be corrupted. Try again.${NC}"
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
    curl --fail -s "$API_URL" | awk -F '"' '/tag_name/{print $4}' | sed 's/GE-Proton//'
}

install_latest_proton_ge () {
    verify_steam_path
    latest_version=$(get_latest_version)
    if [ -z "$latest_version" ]; then
        echo "${RED}Error: failed to determine latest version${NC}"
        echo "${YELLOW}Check your internet connection or GitHub API status.${NC}"
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

show_status () {
    verify_steam_path
    if [ ! -d "$COMPATIBILITYTOOLS_DIR" ]; then
        echo "${YELLOW}No Proton-GE versions installed.${NC}"
        exit 0
    fi
    found=0
    echo "${BLUE}Installed Proton-GE versions:${NC}"
    echo "----------------------------------------"
    for dir in "$COMPATIBILITYTOOLS_DIR"/GE-Proton*; do
        [ -d "$dir" ] || continue
        version="${dir##*/GE-Proton}"
        size=$(du -sh "$dir" 2>/dev/null | awk '{print $1}')
        files=$(find "$dir" -type f | wc -l)
        echo "Version: ${BLUE}$version${NC}"
        echo "  Location: $dir"
        echo "  Size: $size"
        echo "  Files: $files"
        echo "  Status: ${GREEN}Installed${NC}"
        echo ""
        found=1
    done
    if [ "$found" -eq 0 ]; then
        echo "${YELLOW}No Proton-GE versions installed.${NC}"
    fi
    exit 0
}

interactive_mode () {
    verify_steam_path
    echo "${BLUE}Proton-GE Manager Interactive Setup${NC}"
    echo "----------------------------------------"
    
    # Check if any versions are installed
    count=$(ls -1 "$COMPATIBILITYTOOLS_DIR"/GE-Proton* 2>/dev/null | wc -l)
    if [ "$count" -gt 0 ]; then
        echo "${YELLOW}Found $count installed Proton-GE version(s).${NC}"
        echo ""
    fi
    
    # Show menu
    while true; do
        echo "${BLUE}Options:${NC}"
        echo "  1. Install latest Proton-GE version"
        echo "  2. Install specific Proton-GE version"
        echo "  3. List installed versions"
        echo "  4. Show detailed status"
        echo "  5. Remove a version"
        echo "  6. Purge all versions"
        echo "  7. Exit"
        echo ""
        printf "Select an option (1-7): "
        read -r choice
        echo ""
        
        case "$choice" in
            1)
                install_latest_proton_ge
                ;;
            2)
                printf "Enter version (e.g., 9-19): "
                read -r version
                install_proton_ge "$version"
                ;;
            3)
                list_proton_ge
                ;;
            4)
                show_status
                ;;
            5)
                printf "Enter version to remove (e.g., 9-19): "
                read -r version
                remove_proton_ge "$version"
                ;;
            6)
                purge_proton_ge
                ;;
            7)
                echo "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo "${RED}Invalid option. Please try again.${NC}"
                ;;
        esac
        echo ""
    done
}

remove_proton_ge () {
    version=$1
    validate_version "$version"
    target_dir="$COMPATIBILITYTOOLS_DIR/GE-Proton$version"
    if [ ! -d "$target_dir" ]; then
        echo "${RED}Proton-GE $version is not installed.${NC}"
        echo "${YELLOW}Use -L to list installed versions.${NC}"
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
            *) echo "${YELLOW}Aborted.${NC}"
              echo "${YELLOW}Use -y to skip confirmation next time.${NC}"
              exit 1 ;;
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
                echo "${RED}Error: $1 requires a version argument${NC}"
                echo "${YELLOW}Example: $0 $1 9-19${NC}"
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
        -s|--status)
            action="status"
            shift
            ;;
        -r|--remove)
            if [ -z "$2" ]; then
                echo "${RED}Error: $1 requires a version argument${NC}"
                echo "${YELLOW}Example: $0 $1 9-19${NC}"
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
        -I|--interactive)
            action="interactive"
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
            echo "${YELLOW}Run with -h for help.${NC}"
            display_help
            ;;
    esac
done

case "$action" in
    install) install_proton_ge "$action_arg" ;;
    latest)  install_latest_proton_ge ;;
    list)    list_proton_ge ;;
    status)  show_status ;;
    remove)  remove_proton_ge "$action_arg" ;;
    purge)   purge_proton_ge ;;
    interactive) interactive_mode ;;
    "")      display_help ;;
esac
