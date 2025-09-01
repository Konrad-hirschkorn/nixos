{
  pkgs,
  self,
  lib,
  hosts, # list of host names to provide installers for
  hostDisks, # attr-set: host → list of disk paths
  home-manager,
  ...
}: let
  # ────────────────────────────────────────────────────────────────────────────
  # 1.  stand-alone script that replaces the original bash function
  # ────────────────────────────────────────────────────────────────────────────
  installKeysScript = pkgs.writeShellScriptBin "install_keys_from_file" ''
    #! /usr/bin/env bash
    # Copy an id_ed25519 (+ AGE key) into the freshly mounted NixOS target
    set -euo pipefail

    # ─── 1  argument / file checks ───────────────────────────────────────────
    if [[ $# -ne 1 ]]; then
      echo "Usage: $0 /path/to/id_ed25519" >&2
      exit 1
    fi

    INPUT_KEY=$1
    if [[ "$(basename "$INPUT_KEY")" != id_ed25519 ]]; then
      echo "Error: file must be named exactly 'id_ed25519'." >&2
      exit 1
    fi
    [[ -f $INPUT_KEY ]] || {
      echo "Error: '$INPUT_KEY' not found." >&2
      exit 1
    }

    # ─── 2  destination paths (always below /mnt) ────────────────────────────
    ROOT=/mnt
    HOME_MNT="$ROOT$HOME"               # → /mnt/home/<user>
    SSH_DIR="$HOME_MNT/.ssh"
    SOPS_AGE_DIR="$HOME_MNT/.config/sops/age"
    ETC_SSH_DIR="$ROOT/etc/ssh"

    install -m700 -d "$SSH_DIR" "$SOPS_AGE_DIR"
    install -d "$ETC_SSH_DIR"

    DEST_PRIV="$SSH_DIR/id_ed25519"
    DEST_PUB="$SSH_DIR/id_ed25519.pub"
    DEST_AGE_SSH="$SSH_DIR/age_keys.txt"
    DEST_AGE_SOPS="$SOPS_AGE_DIR/keys.txt"
    DEST_ETC="$ETC_SSH_DIR/nixos_personal_sops_key"

    # ─── 3  copy SSH private key ─────────────────────────────────────────────
    install -m600 "$INPUT_KEY" "$DEST_PRIV"

    # ─── 4  ensure public key exists ─────────────────────────────────────────
    if [[ -f "$INPUT_KEY.pub" ]]; then
      install -m644 "$INPUT_KEY.pub" "$DEST_PUB"
    else
      ssh-keygen -y -f "$INPUT_KEY" > "$DEST_PUB"
      chmod 644 "$DEST_PUB"
    fi

    # ─── 5  AGE secret for SOPS ──────────────────────────────────────────────
    command -v ssh-to-age >/dev/null || {
      echo "Error: ssh-to-age not in PATH." >&2
      exit 1
    }

    ssh-to-age -private-key -i "$INPUT_KEY" > "$DEST_AGE_SSH"
    chmod 600 "$DEST_AGE_SSH"
    install -m600 "$DEST_AGE_SSH" "$DEST_AGE_SOPS"

    # ─── 6  copy private key to /mnt/etc for sops-nix ────────────────────────
    install -m600 "$DEST_PRIV" "$DEST_ETC"

    echo "✓ Keys installed under /mnt."
  '';

  # ────────────────────────────────────────────────────────────────────────────
  # 2.  original closure collection (unchanged)
  # ────────────────────────────────────────────────────────────────────────────
  perHostDeps = host: let
    cfg = self.nixosConfigurations.${host};
  in [
    cfg.config.system.build.toplevel
    cfg.config.system.build.diskoScript
    cfg.config.system.build.diskoScript.drvPath
    cfg.pkgs.stdenv.drvPath
    cfg.pkgs.perlPackages.ConfigIniFiles
    cfg.pkgs.perlPackages.FileSlurp
    (cfg.pkgs.closureInfo {rootPaths = [];}).drvPath
  ];

  dependencies =
    builtins.concatMap perHostDeps hosts
    ++ builtins.map (v: v.outPath) (builtins.attrValues self.inputs);

  closureInfo = pkgs.closureInfo {rootPaths = dependencies;};

  # ────────────────────────────────────────────────────────────────────────────
  # 3.  one install script per host (EXTENDED)
  # ────────────────────────────────────────────────────────────────────────────
  mkScript = host:
    pkgs.writeShellScriptBin "install-${host}" ''
      #! /usr/bin/env bash
      set -eux

      if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root." >&2
        exit 1
      fi

      echo
      read -rp "Path to your id_ed25519 key: " KEY_PATH
      if ! install_keys_from_file "$KEY_PATH"; then
        echo "Key installation failed - aborting." >&2
        rm -rf /mnt/etc/nixos
        umount -R /mnt || true
        exit 1
      fi

      # wipe + partition + mount
      nix --extra-experimental-features 'nix-command flakes' run \
        github:nix-community/disko -- --mode zap_create_mount \
        ${self}/common/disko.nix --arg disks '${builtins.toJSON hostDisks.${host}}'

      # copy flake to target
      mkdir -p /mnt/etc/nixos
      git clone https://github.com/Konrad-hirschkorn/nixos.git /mnt/etc/nixos/
      rm -f /mnt/etc/nixos/flake.lock

      # install the system
      nixos-install --flake "/mnt/etc/nixos#${host}"
      reboot
    '';
in {
  imports = [
    ./common.nix
  ];

  # make the closure available on the ISO
  environment.etc."install-closure".source = lib.mkForce "${closureInfo}/store-paths";

  networking.networkmanager.enable = true;

  # ship both the per-host installer *and* the key-install helper
  environment.systemPackages =
    [installKeysScript] ++ builtins.map mkScript hosts;
}
