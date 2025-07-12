# Git Automation Scripts

Scripts for automating Git synchronization and repository management.

## Scripts

- **`git-auto-pull.sh`** - Generates a script for force-syncing local Git repos with remote branches
- **`git-auto-sync-download.sh`** - Downloads and sets up Git auto-sync functionality
- **`git-auto-sync2.sh`** - Alternative Git synchronization script

## Usage

### Auto Pull Setup
```shell
zsh -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/git/git-auto-pull.sh)"
```

### Auto Sync Download
```shell
zsh -c "$(wget -qLO - https://raw.githubusercontent.com/codefuturist/monorepo-public/refs/heads/main/scripts/git/git-auto-sync-download.sh)"
```
