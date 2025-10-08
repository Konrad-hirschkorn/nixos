{
  config,
  pkgs,
  inputs,
  lib,
  backupPaths,
  hostName,
  ...
}: {
  # imports
  imports = [
    # Inline module that turns on Wake-on-LAN for every interface
    ({lib, ...}: {
      options.networking.interfaces = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submoduleWith {
          modules = [
            ({name, ...}: {
              config.wakeOnLan.enable = lib.mkDefault true;
            })
          ];
        });
      };
    })
    inputs.sops-nix.nixosModules.sops
    ../secrets/sops.nix
  ];

  # Open ports in the firewall
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable entirely:
  networking = {
    firewall.enable = true;
    networkmanager.enable = true;

    networkmanager.plugins = with pkgs; [
      networkmanager-openvpn
    ];

   # networkmanager.ensureProfiles.environmentFiles = [
    #  "/run/secrets/wifiENV"
    #];

    networkmanager.ensureProfiles.profiles = {
      "iocto_guest" = {
        connection = {
          id = "iocto_guest";
          type = "wifi";
          autoconnect = true;
        };

        wifi = {
          ssid = "iocto_guest";
          mode = "infrastructure";
        };

        wifi-security = {
          key-mgmt = "wpa-psk";
          psk = "$IOCTO_WIFI_PSK"; # substituted from env file
        };

        ipv4 = {method = "auto";};
        ipv6 = {
          addr-gen-mode = "default";
          method = "auto";
        };
      };
      "Work-VPN" = {
        connection = {
          id = "Work-VPN";
          type = "vpn";
          autoconnect = false;
        };

        vpn = {
          service-type = "org.freedesktop.NetworkManager.openvpn";
          connection-type = "password-tls";

          remote = "vpn1.kr.iocto.com";
          port = "1196";
          # remote-random = "yes"; # second host handled by random fallback

          dev-type = "tun";
          auth = "SHA256";
          remote-cert-tls = "server";
          verify-x509-name = "name:iocto OpenVPN Automation Server";
          ca = "/run/secrets/openvpn_ca";
          extra-certs = "/run/secrets/openvpn_extra_certs";
          cert = "/run/secrets/openvpn_cert";
          key = "/run/secrets/openvpn_key";
          ta = "/run/secrets/openvpn_ta";

          ping = "10";
          ping-restart = "60";
          reneg-seconds = "0";
          password-flags = "2";
          username = "tlisemer";
          connect-timeout = "15";
        };

        ipv4 = {
          method = "auto";
          # ignore-auto-dns = false; # accept the DNS servers sent by the VPN
          ignore-auto-dns = true; # ignore the DNS servers sent by the VPN
          never-default = true; # keep the local default route
          dns = "172.16.2.254;172.22.0.2;172.22.0.3;1.1.1.1;8.8.8.8";
        };
        ipv6 = {
          # addr-gen-mode = "default";
          ignore-auto-dns = true; # ignore the DNS servers sent by the VPN
          method = "auto";
          dns = "fec0:0:0:ffff::1;fec0:0:0:ffff::2;fec0:0:0:ffff::3";
        };
      };
    };
  };

  # Helper scripts
  environment.systemPackages = with pkgs;
    lib.mkAfter [
      # --- install_keys ---------------------------------------------------------
      (pkgs.writeShellScriptBin "install_keys" ''
        #! /usr/bin/env bash
        set -euo pipefail
        trap 'ret=$?; echo "install_keys failed at line $LINENO (exit $ret)" >&2; exit $ret' ERR

        HOME="/home/$USER"
        PRIMARY_KEY_PATH="$HOME/.ssh/id_ed25519"
        SOPS_KEY_PATH="/etc/ssh/nixos_personal_sops_key"
        AGE_KEYS_DIR="$HOME/.config/sops/age"
        AGE_KEYS_PATH="$AGE_KEYS_DIR/keys.txt"

        echo "Checking for primary SSH key…"
        [[ -f "$PRIMARY_KEY_PATH" ]] || { echo "Missing $PRIMARY_KEY_PATH" >&2; exit 1; }

        # Skip work when everything is already there
        if [[ -f "$SOPS_KEY_PATH" && -f "$AGE_KEYS_PATH" ]]; then
          echo "All keys already present - nothing to do."
          exit 0
        fi

        echo "Generating missing keys…"

        if [[ ! -f "$SOPS_KEY_PATH" ]]; then
          echo " → creating $SOPS_KEY_PATH (sudo)…"
          sudo cp "$PRIMARY_KEY_PATH" "$SOPS_KEY_PATH"
        fi

        if [[ ! -f "$AGE_KEYS_PATH" ]]; then
          echo " → creating $AGE_KEYS_PATH"
          command -v ssh-to-age >/dev/null 2>&1 || { echo "ssh-to-age not found" >&2; exit 1; }
          mkdir -p "$AGE_KEYS_DIR"
          ssh-to-age -private-key -i "$PRIMARY_KEY_PATH" >"$AGE_KEYS_PATH"
        fi

        echo "Fixing ownership/permissions…"
        sudo chown root:root "$SOPS_KEY_PATH"
        sudo chmod 600      "$SOPS_KEY_PATH"
        chown  -R "$USER:users" "$HOME/.config/sops"
        chmod 700 "$AGE_KEYS_DIR"
        chmod 600 "$AGE_KEYS_PATH"
        chmod 700 "$HOME/.ssh"
        chmod 600 "$PRIMARY_KEY_PATH"
        chmod 644 "$PRIMARY_KEY_PATH.pub"

        echo "Key installation complete."
      '')

      # --- transfer_and_install_keys -------------------------------------------
      (pkgs.writeShellScriptBin "transfer_and_install_keys" ''
        #! /usr/bin/env bash
        set -euo pipefail

        if [[ $# -ne 1 ]]; then
          echo "Usage: transfer_and_install_keys <host>" >&2
          exit 1
        fi

        HOST="$1"
        REMOTE_USER="$USER@$HOST"
        KEY_PATH="$HOME/.ssh/id_ed25519"
        LOCAL_INSTALL_KEYS_BIN="$(command -v install_keys || true)"

        [[ -f "$KEY_PATH" ]] || { echo "Missing $KEY_PATH" >&2; exit 1; }
        [[ -n "$LOCAL_INSTALL_KEYS_BIN" ]] || { echo "install_keys not in \$PATH" >&2; exit 1; }

        echo "→ copying SSH key…"
        ssh "$REMOTE_USER" 'mkdir -p ~/.ssh'
        scp "$KEY_PATH" "$REMOTE_USER:~/.ssh/id_ed25519"
        scp "$KEY_PATH".pub "$REMOTE_USER:~/.ssh/id_ed25519.pub"

        echo "→ running install_keys on $HOST…"
        ssh "$REMOTE_USER" 'bash install_keys'

        echo "SSH key transferred and install_keys executed successfully on $HOST."
      '')
    ];
}
