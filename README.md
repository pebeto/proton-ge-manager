# proton-ge-manager
A small script to download, install, and remove Proton-GE releases on your system.

> [!NOTE]
> This utility is only compatible with Proton-GE releases from GloriousEggroll's GitHub
> repository, and with the standard directory structure used by Steam across different
> platforms (Steam Deck, Native installation, Flatpak, and Snap).

![Proton-GE Manager in action](./proton-ge-manager.gif)

## Features

- Progress bars for downloads and extractions
- Color-coded output (on terminals that support it; honors `NO_COLOR`)
- Automatic download resume for interrupted transfers
- SHA-512 checksum verification before extraction
- Backup creation before purge operations
- Clear error messages with suggested fixes
- Shell completion for bash and zsh

## Quick start
> [!NOTE]
> These commands fetch the script from a small API that always serves the latest
> version. You can read the endpoint source [here](https://github.com/pebeto/pebeto.github.io/blob/master/app/api/pgm/%5Btype%5D/route.tsx).

### Install the latest Proton-GE

Run the line for your platform:

- Steam Deck
    ```bash
    sh -c "$(curl -fsSL https://pebeto.github.io/api/pgm/steamdeck) -l"
    ```

- Steam (Native)
    ```bash
    sh -c "$(curl -fsSL https://pebeto.github.io/api/pgm/native) -l"
    ```

- Steam (Flatpak)
    ```bash
    sh -c "$(curl -fsSL https://pebeto.github.io/api/pgm/flatpak) -l"
    ```

- Steam (Snap)
    ```bash
    sh -c "$(curl -fsSL https://pebeto.github.io/api/pgm/snap) -l"
    ```

Once it finishes, restart Steam, right-click a game, open **Properties → Compatibility**, and pick the new Proton-GE version from the dropdown. On Steam Deck, switch back to Gaming Mode to apply the change.

### Install the manager (for repeat use)

The command above downloads the script, runs it once, and discards it. To manage versions over time, save it to your `PATH` instead. Replace `native` with your platform (`steamdeck`, `native`, `flatpak`, or `snap`):

```bash
curl -fsSL https://pebeto.github.io/api/pgm/native -o ~/.local/bin/proton-ge-manager
chmod +x ~/.local/bin/proton-ge-manager
proton-ge-manager -l
```

If `~/.local/bin` is not on your `PATH`, add it or choose another directory that is. After this, run `proton-ge-manager` directly with any command.

## Commands

- `-i, --install <version>`: Install a specific Proton-GE version (e.g., `./proton-ge-manager.sh -i 9-10`). Skips download if already installed; use `-f` to force reinstall.
- `-l, --latest`: Install the latest Proton-GE version automatically.
- `-L, --list`: List installed Proton-GE versions.
- `-s, --status`: Show detailed status including version, location, size, and file count.
- `-r, --remove <version>`: Remove a specific Proton-GE version.
- `-p, --purge`: Remove ALL installed Proton-GE versions. Offers backup option before deletion.
- `-I, --interactive`: Launch interactive setup wizard for guided installation.
- `-f, --force`: Force reinstallation even if version is present.
- `-y, --yes`: Skip all confirmation prompts.
- `-h, --help`: Display this help message.

Run `./proton-ge-manager.sh -h` to print this list at any time.

## Examples

Create a backup before purging everything:
```bash
./proton-ge-manager.sh -p
# answer "y" to purge, then "y" to create the backup
```

Reinstall a version you already have:
```bash
./proton-ge-manager.sh -i 9-19 -f
```

Install the latest version without any prompts:
```bash
./proton-ge-manager.sh -l -y
```

## Configuration

Set these environment variables before running the script:

- `COMPATIBILITYTOOLS_DIR`: Override the default Steam compatibility tools directory
- `NO_COLOR`: Set to any value to disable color output

Example:
```bash
COMPATIBILITYTOOLS_DIR=/custom/path ./proton-ge-manager.sh -l
```

## Shell completion

The completion scripts ship in this repository, so clone it first:
```bash
git clone https://github.com/pebeto/proton-ge-manager.git
```

Then source the script for your shell.

### Bash

Add to your `~/.bashrc`:
```bash
source /path/to/proton-ge-manager/scripts/proton-ge-manager-completion.bash
```

### Zsh

Add to your `~/.zshrc`:
```zsh
source /path/to/proton-ge-manager/scripts/proton-ge-manager-completion.zsh
```

Reload with `source ~/.bashrc` or `source ~/.zshrc` to enable completion.

## Troubleshooting

**Steam path not found**:
```
Steam compatibility tools directory not found at: /path/to/dir
```
- Ensure Steam is installed
- Launch Steam at least once
- Check your Steam installation path

**Download failed**:
```
Error: failed to download Proton-GE X-Y
```
- Check your internet connection
- Try again later (GitHub may be rate limiting)
- Downloads resume automatically if interrupted

**Checksum mismatch**:
```
Error: checksum mismatch
```
- The download may be corrupted
- Try downloading again
- Ensure you have enough disk space

**Invalid version format**:
```
Error: invalid version format: invalid
```
- Use format like `9-19` or `10-0`
- Check available versions on [GloriousEggroll's GitHub](https://github.com/GloriousEggroll/proton-ge-custom/releases)
