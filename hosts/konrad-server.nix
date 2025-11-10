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

  networking.networkmanager.insertNameservers = [
    "1.1.1.1" # Primary: Cloudflare DNS
    "8.8.8.8" # Backup: Google DNS
    "2606:4700:4700::1111" # Cloudflare IPv6
    "2001:4860:4860::8888" # Google DNS IPv6
  ];

  networking.firewall = {
    enable = true;
    # TCP ports to open
    allowedTCPPorts = [
      22 # SSH
      80 # Traefik HTTP
      443 # HTTPS / Traefik
      2283 # Immich server
      3080 # LibreChat
      4743 # Vaultwarden
      8123 # Home Assistant
      9001 # Portainer agent
      25565 # Minecraft server
    ];
    # WireGuard UDP-Port entfernt, da nicht mehr benötigt
    allowedUDPPorts = [];
    trustedInterfaces = ["docker0" "lo"];
    allowPing = true;
  };


  # Der WireGuard-Block wurde komplett entfernt.
  # Stattdessen wird der folgende systemd-Dienst für den SSH-Tunnel verwendet.

  systemd.services.minecraft-tunnel = {
    description = "SSH Reverse Tunnel for Minecraft Server";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      # Wichtig: Als dein normaler Benutzer ausführen, nicht als root
      User = "konrad";

      # Der Befehl, der den Tunnel aufbaut
      ExecStart = ''
        ${pkgs.openssh}/bin/ssh -N -R 0.0.0.0:25565:localhost:25565 -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes root@82.165.145.27
      '';

      # Immer neu starten, wenn der Dienst fehlschlägt
      Restart = "always";
      RestartSec = "10";
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
        ENABLE_RCON = "true";
        ENABLE_WHITELIST = "false";
        ONLINE_MODE = "true";
        DIFFICULTY = "hard";
      };
    };
  };
}
