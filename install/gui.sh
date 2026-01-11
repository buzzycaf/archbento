#!/usr/bin/env bash

[[ "${ARCHBENTO_INSTALL_CONTEXT:-}" == "1" ]] || {
  echo "ERROR: install/gui.sh must be sourced by install.sh" >&2
  exit 1
}

gui_install_packages() {
    # Hyprland desktop stack.
  # This is a conservative starter set that boots cleanly.
  
  local pkgs=(
    ########################################
    #          KDE Base Backend
    ########################################
    systemsettings # KDE System Settings app (display, input, themes, etc.)
    kconfig        # KDE config system (used by many KDE apps)
    kcoreaddons    # Core KDE runtime utilities
    kservice       # Service discovery / desktop integration
    ki18n          # Internationalization support (quiet dependency, but needed)
    swww           # Wayland-native wallpaper daemon for Hyprland; scriptable, lightweight, supports transitions
    zenity         # Simple GUI dialog helper for shell scripts (file pickers, confirmations, prompts, progress); used by Wayland/Hyprland workflows and utilities

    # KDE I/O Layer
    # This is what lets Dolphin, file dialogs, and Qt apps behave correctly.
    kio            # Core virtual filesystem (trash:/, recent:/, etc.)
    kio-extras     # smb://, sftp://, mtp://, trash integration, network browsing

    # Qt theming & consistency
    # Keeps Qt apps sane and themeable outside Plasma.
    qt6ct           # Qt configuration tool (theme, fonts, scaling)
    breeze          # Clean, neutral Qt widget style
    breeze-icons    # KDE icon theme (fallback-safe, widely supported)

    # (Optional but common)
    oxygen-icons    # (optional fallback set)
  
    # Portals (KDE as backend, Hyprland as compositor)
    xdg-desktop-portal          # Core portal dispatcher; routes requests to the correct backend
    xdg-desktop-portal-kde      # KDE backend for portals (file chooser, integration)
    xdg-desktop-portal-hyprland # Hyprland backend (Wayland-native screencast, screenshots)
  
    # Polkit (KDE-native agent similar to Windows UAC)
    # Avoids GTK creep and keeps auth dialogs consistent.
    polkit
    polkit-kde-agent            # this replaces polkit-gnome

    ########################################
    #    Hyprland Functional Base
    ########################################
    hyprland          # the compositor itself
    xorg-xwayland     # X11 wayland emulator
    dbus              # IPC message bus; required for desktop services to talk to each other
  
    ########################################
    #    Other base functionality needed
    ########################################
    mako                      # enables desktop notifications
    ttf-dejavu                # Base system font; sane default for UI text and Unicode coverage
    ttf-jetbrains-mono-nerd   # Terminal font with Nerd Font glyphs (icons, prompts, tmux)
    swayimg                   # Lightweight Wayland-native image viewer; fast image previews without pulling in a full desktop image suite
  
    # Audio stack
    pipewire          # Core audio/video server; replaces PulseAudio + JACK
    wireplumber       # Session/policy manager: decides which devices/apps connect and how
    pipewire-alsa     # ALSA compatibility layer so legacy ALSA apps produce sound
    pipewire-pulse    # PulseAudio compatibility layer for apps expecting PulseAudio
  
    # Screenshots and basic debugging
    grim              # screenshot capture
    slurp             # region selection
    wev               # input event debugging
    kitty             # terminal emulator
  )

  log "Installing GUI packages (Hyprland stack)..."
  run "sudo pacman -S --needed --noconfirm ${pkgs[*]}"
}

gui_install_tools() {
  # Optional desktop tools (QOL). Keep this tight.
  local pkgs=(
  
    ########################################
    #        File Managers (GUI / TUI)
    ########################################
    dolphin        # KDE file manager; native KIO integration (smb://, sftp://, trash:/), Qt-themed, no Plasma required
    yazi           # Terminal file manager with GPU-accelerated previews; fast, keyboard-driven, works great in kitty

    ########################################
    #        Login & Session Management
    ########################################
    greetd-tuigreet  # Minimal login manager (display manager replacement) TUI greeter for greetd; keyboard-first, themeable, no GTK/Qt deps

    ########################################
    #        System Interaction Utilities
    ########################################
    hyprlock       # Hyprland-native lock screen
    hypridle       # Idle detection; triggers lock/suspend actions

    ########################################
    #        App Launchers
    ########################################
    fuzzel         # Wayland-native app launcher (fast, simple, no GTK/Qt baggage)

    ########################################
    #        Flatpak App Management
    ########################################
    flatpak        # Flatpak runtime and CLI
    bazaar         # Flatpak-only GUI app store (clean, modern, SteamOS-style UX)
    # flatseal       # Flatpak permission manager (GUI)
 
    ########################################
    #        Input & Workflow Helpers
    ########################################
    cliphist       # Clipboard history manager (text + images) for wl-clipboard
    keyd           # System-wide input remapping (TTY + Wayland-safe)
    kwrite         # Lightweight Qt text editor (Notepad-style scratchpad)
    qalculate-qt   # Powerful Qt-based calculator (GUI); supports units, currency, symbolic math, and scripting — lightweight desktop utility
    kcharselect    # KDE Unicode and emoji picker; browse, search, and insert Unicode characters without pulling in Plasma
    hyprpicker     # Hyprland-native color picker; click anywhere on screen to copy color values (hex/RGB) — Wayland-native, minimal

    ########################################
    #        Sensor Panel Providers / Helpers
    ########################################
    sysstat        # Disk activity telemetry (iostat) for read/write widgets
    mesa-utils     # Cross-vendor GPU diagnostics (AMD/Intel/Mesa baseline)
    # nvidia-utils   # NVIDIA GPU telemetry (nvidia-smi), used when applicable
    chromium       # Default web browser + Home Assistant dashboard display

    ########################################
    #        Network Control (Optional)
    ########################################
    network-manager-applet   # nm-applet; quick Wi-Fi/VPN control via tray
  )

  log "Installing GUI tools (file manager, launcher, utilities)..."
  run "sudo pacman -S --needed --noconfirm ${pkgs[*]}"
}

gui_install_tools_aur() {
  # Optional desktop tools from AUR only.
  # This function assumes yay is already installed and working.
  local pkgs=(

    ########################################
    #        Wayland / Desktop Enhancements
    ########################################
    avizo          # Wayland OSD overlays (volume/brightness sliders); lightweight, compositor-agnostic

    ########################################
    #        (Future AUR GUI Tools)
    ########################################
    # example-aur-pkg
  )

  # If nothing is enabled yet, exit cleanly
  [[ ${#pkgs[@]} -eq 0 ]] && return 0

  log "Installing GUI tools from AUR (yay)..."
  run "yay -S --needed --noconfirm ${pkgs[*]}"
}

gui_install_tools_flatpak() {
  # Optional GUI tools delivered via Flatpak only.
  # Flatseal lives on Flathub and should never be installed via pacman or AUR.

  # Ensure flatpak exists (installed earlier via pacman)
  if ! command -v flatpak >/dev/null 2>&1; then
    log "Flatpak not found; skipping Flatpak GUI tools."
    return 0
  fi

  # Ensure Flathub remote exists
  if ! flatpak remote-list | awk '{print $1}' | grep -qx flathub; then
    log "Adding Flathub remote..."
    run "flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"
  fi

  local pkgs=(
    com.github.tchx84.Flatseal   # Flatpak permission manager (GUI)
  )

  log "Installing GUI tools from Flatpak (Flathub)..."
  run "flatpak install -y flathub ${pkgs[*]}"
}

gui_install_post_login_fixes() {
  log "Installing post-login fixes (portals)..."

  run "mkdir -p '$HOME/.local/bin' '$HOME/.local/state/archbento' '$HOME/.config/systemd/user'"
  
  # 1) Script: one-time portal enable/restart with a stamp file
  write_file "$HOME/.local/bin/archbento-portal-fix.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

STAMP="$HOME/.local/state/archbento/portal-fixed"
[[ -f "$STAMP" ]] && exit 0

mkdir -p "$(dirname "$STAMP")"

systemctl --user restart xdg-desktop-portal.service >/dev/null 2>&1 || true
systemctl --user restart xdg-desktop-portal-hyprland.service >/dev/null 2>&1 || true

touch "$STAMP"
EOF

  run "chmod +x '$HOME/.local/bin/archbento-portal-fix.sh'"

  # 2) User systemd unit: run once after login
  write_file "$HOME/.config/systemd/user/archbento-portal-fix.service" <<'EOF'
[Unit]
Description=Archbento one-time XDG portal sanity check

[Service]
Type=oneshot
ExecStart=%h/.local/bin/archbento-portal-fix.sh

[Install]
WantedBy=default.target
EOF

  # 3) Enable it if possible (best effort)
  log "Enabling archbento-portal-fix user service (best effort)..."
  run "systemctl --user daemon-reload >/dev/null 2>&1 || true"
  run "systemctl --user enable --now archbento-portal-fix.service >/dev/null 2>&1 || true"
}

gui_enable_services() {
  log "Enabling user audio services (WirePlumber)..."
  run "systemctl --user enable --now wireplumber.service || true"

  log "Starting user XDG Desktop Portal services (best effort)..."
  run "systemctl --user daemon-reload >/dev/null 2>&1 || true"
}

gui_notes() {
  log "GUI installed."
  echo "Next: add Hyprland start command (TTY login):"
  echo "  - temporarily run: Hyprland"
  echo "  - later we’ll add a safe autostart in ~/.zprofile"
}

# This function isn't being currently used in main(), but leaving it just in case.
gui_set_gtk_dark_mode() {
  log "Setting GTK dark mode preference (prefer-dark)..."

  if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
  else
    log "WARN: gsettings not found; GTK dark mode not applied"
  fi
}
