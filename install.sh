#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${HOME}/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

log() { printf "\n==> %s\n" "$*"; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "ERROR: missing required command: $1" >&2
    exit 1
  }
}

backup_if_exists() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    mkdir -p "$BACKUP_DIR"
    log "Backing up $target -> $BACKUP_DIR/"
    mv "$target" "$BACKUP_DIR/"
  fi
}

link_file() {
  local src="$1"
  local dst="$2"
  dst="${dst/#\~/$HOME}"

  # Already linked correctly?
  if [[ -L "$dst" ]]; then
    local current
    current="$(readlink "$dst")"
    if [[ "$current" == "$src" ]]; then
      log "OK: $dst already linked"
      return 0
    fi
  fi

  backup_if_exists "$dst"
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  log "Linked: $dst -> $src"
}

link_dir_contents() {
  local src_dir="$1"
  local dst_dir="$2"
  mkdir -p "$dst_dir"

  shopt -s nullglob
  for item in "$src_dir"/*; do
    local base
    base="$(basename "$item")"
    link_file "$item" "$dst_dir/$base"
  done
}

install_packages() {
  # git is intentionally NOT included (you needed it to clone this repo)
  local pkgs=(
    neovim less man-db man-pages
    base-devel curl wget ripgrep fd unzip zip tar
    tree bat which
    htop lsof pciutils usbutils
    networkmanager
    gnupg openssh
    dosfstools e2fsprogs ntfs-3g
    fzf zoxide zsh starship
  )

  log "Installing foundation packages (excluding git)..."
  sudo pacman -S --needed --noconfirm "${pkgs[@]}"
}

enable_networking() {
  log "Enabling NetworkManager..."
  sudo systemctl enable --now NetworkManager
}

link_dotfiles() {
  log "Linking dotfiles from $REPO_DIR"
  log "Backup dir: $BACKUP_DIR (only created if backups needed)"

  # zsh dotfiles
  [[ -f "$REPO_DIR/zsh/zshrc" ]]     && link_file "$REPO_DIR/zsh/zshrc" "$HOME/.zshrc"
  [[ -f "$REPO_DIR/zsh/zprofile" ]]  && link_file "$REPO_DIR/zsh/zprofile" "$HOME/.zprofile"

  # starship
  if [[ -f "$REPO_DIR/starship/starship.toml" ]]; then
    mkdir -p "$HOME/.config"
    link_file "$REPO_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
  elif [[ -d "$REPO_DIR/starship" ]]; then
    link_dir_contents "$REPO_DIR/starship" "$HOME/.config/starship"
  fi

  # optional future: hypr/waybar/ghostty
  [[ -d "$REPO_DIR/hypr"    ]] && link_dir_contents "$REPO_DIR/hypr"    "$HOME/.config/hypr"
  [[ -d "$REPO_DIR/waybar"  ]] && link_dir_contents "$REPO_DIR/waybar"  "$HOME/.config/waybar"
  [[ -d "$REPO_DIR/ghostty" ]] && link_dir_contents "$REPO_DIR/ghostty" "$HOME/.config/ghostty"

  log "Dotfiles linking complete."
  if [[ -d "$BACKUP_DIR" ]]; then
    log "Backups saved in: $BACKUP_DIR"
  fi
}

set_zsh_shell() {
  # Don’t force it—only change if user confirms via env var
  # Usage: DOTFILES_SET_SHELL=1 ./install.sh
  if [[ "${DOTFILES_SET_SHELL:-0}" == "1" ]]; then
    log "Setting default shell to zsh for user $USER..."
    need_cmd zsh
    chsh -s "$(command -v zsh)"
    log "Shell changed. Log out and back in, or run: exec zsh"
  else
    log "Skipping shell change. To set zsh as default, run:"
    echo "    DOTFILES_SET_SHELL=1 ./install.sh"
  fi
}

main() {
  need_cmd readlink
  need_cmd ln
  need_cmd mv
  need_cmd mkdir
  need_cmd date

  # If pacman exists, we’re on Arch (or Arch-based)
  need_cmd pacman

  install_packages
  enable_networking
  link_dotfiles
  set_zsh_shell

  log "All done."
}

main "$@"
