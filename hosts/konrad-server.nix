{
  modulesPath,
  config,
  pkgs,
  inputs,
  home-manager,
  lib,
  disks,
  users,
  ...
}: {
  # Import the common configuration shared across all machines
  imports = [
    ../common/after_installer.nix
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    (import ../common/disko.nix {inherit disks;})
    ../common/common.nix
    ../packages/vscode.nix
    ../packages/system-packages.nix
    ../packages/dependencies.nix
    (import ../common/home-manager.nix {
      inherit config pkgs inputs home-manager lib users;
      isDesktop = false;
      isWsl = false;
      isServer = true;
      isHomeAssistant = false;
    })
  ];

  # Fix shebangs in scripts
  services.envfs.enable = true;

  # Bootloader
  boot.loader.timeout = lib.mkForce 1;
  boot.loader.grub = lib.mkForce {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  # Machine specific configurations
  environment.variables.SERVER = "1";
  networking = {
    networkmanager = {
      enable = true; # Gehe davon aus, dass das in deinem common.nix steht, ansonsten hier hinzufügen
      insertNameservers = [
        "1.1.1.1" # Primary: Cloudflare DNS
        "8.8.8.8" # Backup: Google DNS
        "2606:4700:4700::1111" # Cloudflare IPv6
        "2001:4860:4860::8888" # Google DNS IPv6
      ];
      # DIESE ZEILE IST NEU UND ENTSCHEIDEND:
      unmanaged = ["interface-name:wg0"];
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [22 80 443 2283 3080 4743 8123 9001 25565];
      allowedUDPPorts = [51820];
      trustedInterfaces = ["docker0"];
      allowPing = true;
    };

    wireguard = {
      enable = true;
      interfaces = {
        wg0 = {
          ips = ["172.31.0.99/24"];
          privateKeyFile = "/etc/wireguard/server_private.key";
          listenPort = 51820;
          mtu = 1420;
          peers = [
            {
              publicKey = "e80QTHVzssveF/d4ylLhnq06+pHLt27L/pl/cqC5TRg=";
              endpoint = "[2a02:2479:75:2a00::1]:51820";
              allowedIPs = ["172.31.0.1/32"];
              persistentKeepalive = 25;
            }
          ];
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [];

  virtualisation.docker.storageDriver = "btrfs";

  virtualisation.docker.rootless.enable = lib.mkForce false;
  virtualisation.docker.rootless.setSocketVariable = lib.mkForce false;

  systemd.services.docker.serviceConfig.ExecStartPost = [
    "${pkgs.coreutils}/bin/chmod 0660 /var/run/docker.sock"
  ];

  virtualisation.oci-containers.containers = {
    portainer = {
      image = "portainer/portainer-ce:latest";
      autoStart = true;
      autoRemoveOnStop = false;
      extraOptions = ["--network=docker-network" "--ip=172.18.0.3"];
      ports = [
        "8000:8000"
        "9443:9443"
      ];
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
        "/mnt/docker-data/volumes/portainer_data:/data"
      ];
    };

    minecraft-server = {
      image = "itzg/minecraft-server:latest";
      autoStart = true;
      autoRemoveOnStop = false;
      # extraOptions entfernt, um das Standard-Netzwerk zu verwenden
      ports = ["0.0.0.0:25565:25565"];
      volumes = [
        "/mnt/docker-data/volumes/minecraft:/data:rw"
      ];
      environment = {
        EULA = "TRUE";
        VERSION = "LATEST";
        MEMORY = "12G";
        ENABLE_RCON = "false";
        ENFORCE_WHITELIST = "TRUE";
        OVERRIDE_WHITELIST = "TRUE";
        WHITELIST = ''
          KONRAD_1312
          schle1cherr
          Hamburgerficker
          Oak_1312
          machseweck
        '';
      };
    };
  };
}
