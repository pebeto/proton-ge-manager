# proton-ge-manager
A simple script to manage Proton-GE releases on your system. Simplifies the process of downloading, installing, and removing Proton-GE releases.

> [!NOTE]
> This utility is only compatible with Proton-GE releases from GloriousEggroll's GitHub
> repository, and with the standard directory structure used by Steam across different
> platforms (Steam Deck, Native installation, Flatpak, and Snap).

![Proton-GE Manager in action](./proton-ge-manager.gif)

## Simple usage
> [!NOTE]
> The endpoint used in the following examples is a simple API that provides the latest
> script version. You can see the endpoint source code [here](https://github.com/pebeto/pebeto.github.io/blob/master/app/api/pgm/%5Btype%5D/route.tsx)
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

After the process is complete, you will be able to use the latest version of Proton-GE in your Steam client. To do so, open (restart) the Steam client, right-click on a game, select **Properties**, go to the **Compatibility** tab, and select the downloaded version of Proton-GE from the dropdown menu.
In case of using the Steam Deck, switch back to Gaming Mode to apply the changes.

## Advanced usage
The script provides a simple interface to manage Proton-GE releases on your system. The following commands are available:
- `-i, --install`: Install a specific Proton-GE version (`./proton-ge-manager.sh -i 9-10`). Skips download if the version is already installed; pass `-f` to reinstall.
- `-l, --latest`: Install the latest Proton-GE version (`./proton-ge-manager.sh -l`).
- `-L, --list`: List installed Proton-GE versions (`./proton-ge-manager.sh -L`).
- `-s, --status`: Show detailed status of installed versions including size and file count.
- `-r, --remove`: Remove an installed Proton-GE version (`./proton-ge-manager.sh -r 9-10`).
- `-p, --purge`: Remove all installed Proton-GE versions (`./proton-ge-manager.sh -p`). Prompts for confirmation; pass `-y` to skip.
- `-I, --interactive`: Launch interactive setup wizard for guided installation.
- `-f, --force`: Reinstall even if the version is already present.
- `-y, --yes`: Skip confirmation prompts.
- `-h, --help`: Display the help message.
    ```bash
    > sh scripts/native/proton-ge-manager.sh -h
    Usage: proton-ge-manager.sh [OPTION]

    Options:
      -h, --help      Display this help message
      -i, --install   Install specific Proton-GE version
      -l, --latest    Install latest Proton-GE version
      -L, --list      List installed Proton-GE versions
      -r, --remove    Remove an installed Proton-GE version
      -p, --purge     Remove all installed Proton-GE versions
      -f, --force     Reinstall even if the version is already present
      -y, --yes       Skip confirmation prompts
    ```

Downloads are verified against the upstream `.sha512sum` published with each release before extraction.

## Shell Completion

For enhanced command-line experience, enable shell completion:

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

After adding, run `source ~/.bashrc` or `source ~/.zshrc` to enable completion.
