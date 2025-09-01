#!/usr/bin/env bash
###############################################################################
# install.sh
#
# • install_keys  – prompt for an id_ed25519 key and copy artefacts to /mnt
# • nixos_install – (host disks…)  run full disko + NixOS install workflow
# • main section  – dispatch based on CLI args with helpful defaults/info
###############################################################################
set -euo pipefail

###############################################################################
# install_keys  —  interactive copy of id_ed25519 + age keys to /mnt
###############################################################################
install_keys() {
    set -euo pipefail
    local INPUT_KEY

    read -r -p "Full path to your id_ed25519 private key: " INPUT_KEY
    [[ -z "$INPUT_KEY" ]] && {
        echo "Error: no path entered." >&2
        return 1
    }
    [[ "$(basename "$INPUT_KEY")" != "id_ed25519" ]] && {
        echo "Error: file must be named exactly 'id_ed25519'." >&2
        return 1
    }
    [[ ! -f "$INPUT_KEY" ]] && {
        echo "Error: '$INPUT_KEY' not found." >&2
        return 1
    }

    local ROOT="/mnt"
    local HOME_MNT="$ROOT$HOME"
    local SSH_DIR="$HOME_MNT/.ssh"
    local SOPS_AGE_DIR="$HOME_MNT/.config/sops/age"
    local ETC_SSH_DIR="$ROOT/etc/ssh"

    mkdir -p "$SSH_DIR" "$SOPS_AGE_DIR" "$ETC_SSH_DIR"
    chmod 700 "$SSH_DIR" "$SOPS_AGE_DIR"

    local DEST_PRIV="$SSH_DIR/id_ed25519"
    local DEST_PUB="$SSH_DIR/id_ed25519.pub"
    local DEST_AGE_SSH="$SSH_DIR/age_keys.txt"
    local DEST_AGE_SOPS="$SOPS_AGE_DIR/keys.txt"
    local DEST_ETC="$ETC_SSH_DIR/nixos_personal_sops_key"

    cp -f "$INPUT_KEY" "$DEST_PRIV"
    chmod 600 "$DEST_PRIV"

    if [[ -f "${INPUT_KEY}.pub" ]]; then
        cp -f "${INPUT_KEY}.pub" "$DEST_PUB"
    else
        ssh-keygen -y -f "$INPUT_KEY" >"$DEST_PUB"
    fi
    chmod 644 "$DEST_PUB"

    if ! command -v ssh-to-age >/dev/null 2>&1; then
        echo "Error: ssh-to-age not found in PATH." >&2
        return 1
    fi
    ssh-to-age -private-key -i "$INPUT_KEY" >"$DEST_AGE_SSH"
    chmod 600 "$DEST_AGE_SSH"
    cp -f "$DEST_AGE_SSH" "$DEST_AGE_SOPS"
    chmod 600 "$DEST_AGE_SOPS"

    if [[ "$(id -u)" -eq 0 ]]; then
        cp -f "$DEST_PRIV" "$DEST_ETC"
        chmod 600 "$DEST_ETC"
    else
        sudo cp -f "$DEST_PRIV" "$DEST_ETC"
        sudo chmod 600 "$DEST_ETC"
    fi

    echo "✔ Keys installed under /mnt."
}

###############################################################################
# nixos_install <host> <disk1> [disk2 …]
###############################################################################
nixos_install() {
    set -euo pipefail
    local HOST=$1
    shift
    local -a DISKS=("$@")

    # --- parameter sanity ----------------------------------------------------
    [[ -z "$HOST" ]] && {
        echo "Error: host string is empty." >&2
        return 1
    }
    [[ ${#DISKS[@]} -eq 0 ]] && {
        echo "Error: no disk paths supplied." >&2
        return 1
    }

    # verify each disk path looks like /dev/*
    for d in "${DISKS[@]}"; do
        [[ "$d" =~ ^/dev/[^/]+$ ]] || {
            echo "Error: '$d' is not a valid /dev/<disk> path." >&2
            return 1
        }
    done

    # Build disko-style array: [ "/dev/xxx" "/dev/yyy" ]
    local DISK_NIX="[ $(printf '"%s" ' "${DISKS[@]}")]"
    DISK_NIX="${DISK_NIX% }" # trim trailing space, close bracket` | `    # Build disko-style array: [ "/dev/xxx" "/dev/yyy" ]`<br>`    local _disko_items`<br>`    _disko_items=$(printf '"%s" ' "${DISKS[@]}")`<br>`    local DISK_NIX="[ ${_disko_items% } ]"` | Guarantees a properly closed bracket and no trailing space, regardless of how many disks are supplied. |

    echo "→ Generating hardware-configuration.nix"
    sudo nixos-generate-config --no-filesystems --show-hardware-config \
        >>hosts/hardware-configuration.nix

    echo "→ Running disko for disks ${DISKS[*]}"
    sudo nix --extra-experimental-features 'nix-command flakes' \
        run github:nix-community/disko -- \
        --mode zap_create_mount ./common/disko.nix --arg disks "$DISK_NIX"

    echo "→ Copying flake + configs to /mnt"
    sudo mkdir -p /mnt/etc/nixos
    sudo cp -a ./* /mnt/etc/nixos/

    echo "→ Installing keys"
    if ! install_keys; then
        echo "Error during install_keys – aborting nixos_install." >&2
        return 1
    fi

    echo "→ Running nixos-install for host '$HOST'"
    sudo nixos-install -L --flake "/mnt/etc/nixos/flake.nix#$HOST"

    echo "✔ Installation complete. Rebooting in 10 s …"
    for i in {10..1}; do
        printf '\rRebooting in %2d s …' "$i"
        sleep 1
    done
    echo
    sudo reboot
}

###############################################################################
# main dispatcher  ------------------------------------------------------------
###############################################################################
declare -A DEFAULT_DISKS=(
    ["konrad-server"]="/dev/sda"
    ["konrad-pc"]="/dev/nvme0n1 /dev/nvme1n1"
    ["konrad-laptop"]="/dev/nvme0n1 /dev/nvme1n1"
    ["konrad-homeassistant"]="/dev/nvme0n1"
    ["qemu"]="/dev/vda"
)

print_help() {
    cat <<EOF
Usage:
  ./install.sh <host> [disk1 disk2 …]

If <host> is one of the predefined names below and no disks are supplied,
the default disk list for that host is used.  Supplying disks overrides
the defaults.

Available hosts and their default disks:
  konrad-server        -> /dev/sda
  konrad-pc            -> /dev/nvme0n1 /dev/nvme1n1
  konrad-laptop        -> /dev/nvme0n1 /dev/nvme1n1
  konrad-homeassistant -> /dev/nvme0n1
  qemu              -> /dev/vda

Example:
  ./install.sh konrad-pc
  ./install.sh konrad-pc /dev/nvme0n1 /dev/nvme1n1
EOF
}

main() {

    # Make sure we have root privileges
    if [[ "$(id -u)" -ne 0 ]]; then
        echo "Error: this script must be run as root." >&2
        exit 1
    fi

    # Try if ssh-to-age is available
    if ! command -v ssh-to-age >/dev/null 2>&1; then
        echo "Error: ssh-to-age not installed. To install do: nix-shell -p ssh-to-age" >&2
        exit 1
    fi

    local RAW_HOST=${1-}
    local HOST=${RAW_HOST//\"/}
    shift || true # may shift zero args

    if [[ -z "$HOST" ]]; then
        print_help
        exit 0
    fi

    # Validate host
    if [[ -z "${DEFAULT_DISKS[$HOST]:-}" ]]; then
        echo "Error: unknown host '$HOST'." >&2
        print_help
        exit 1
    fi

    local -a DISKS
    if [[ $# -eq 0 ]]; then
        # use defaults
        read -ra DISKS <<<"${DEFAULT_DISKS[$HOST]}"
    else
        DISKS=("$@")
    fi

    nixos_install "$HOST" "${DISKS[@]}"
}

main "$@"
