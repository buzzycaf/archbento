# Archbento 🍱
A curated, intentional Arch Linux setup — inspired by Omarchy.

No secrets in this repo

Machine-specific configs belong elsewhere

#### Installation (Fresh Arch Linux)
1. After a fresh Arch Install
   ```bash
   sudo pacman -S git
   mkdir -p ~/git_repositories
   cd ~/git_repositories
   git clone https://github.com/buzzycaf/archbento
   cd dotfiles
   chmod +x install.sh
   ./install.sh
   ```
2. Enable the new shell
   ```bash
   chsh -s /bin/zsh
   ```
3. Log off and back in again, or reboot.

This repository is private and intended for personal use.
