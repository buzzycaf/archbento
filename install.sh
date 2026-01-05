#!/usr/bin/env bash
set -euo pipefail

# dotfiles install script
# - backs up existing targets
# - symlinks repo files into ~/.config and ~/
# - safe to re-run

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

  # Expand ~ in dst safely
  dst="${dst/#\~/$HOME}"

  # If dst is already the correct symlink, do nothing
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

main() {
  need_cmd ln
  need_cmd mv
  need_cmd mkdir
  need_cmd date
  need_cmd readlink

  log "Dotfiles repo: $REPO_DIR"
  log "Backup dir:   $BACKUP_DIR"

  # --- Root dotfiles (if you store them under zsh/) ---
  if [[ -f "$REPO_DIR/zsh/zshrc" ]]; then
    link_file "$REPO_DIR/zsh/zshrc" "$HOME/.zshrc"
  fi
  if [[ -f "$REPO_DIR/zsh/zprofile" ]]; then
    link_file "$REPO_DIR/zsh/zprofile" "$HOME/.zprofile"
  fi

  # --- ~/.config mappings ---
  if [[ -d "$REPO_DIR/starship" ]]; then
    # expects starship/starship.toml
    if [[ -f "$REPO_DIR/starship/starship.toml" ]]; then
      link_file "$REPO_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
    else
      # If you instead keep config in starship/ as multiple files, link the folder
      link_dir_contents "$REPO_DIR/starship" "$HOME/.config/starship"
    fi
  fi

  if [[ -d "$REPO_DIR/hypr" ]]; then
    link_dir_contents "$REPO_DIR/hypr" "$HOME/.config/hypr"
  fi

  if [[ -d "$REPO_DIR_]()]()
