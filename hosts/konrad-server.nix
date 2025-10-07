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

  # Fix shebangs in scripts # Try to bring this back to common/common.nix however currently it breaks a lot of things for example npm
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

  networking.firewall = lib.mkForce {
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

    # UDP ports to open
    allowedUDPPorts = [
    ];

    # ICMP (ping) is allowed separately
    allowPing = true;
  };

  environment.systemPackages = with pkgs; [
  ];

  virtualisation.docker.storageDriver = "btrfs";

  # Override the common.nix docker configuration for the server
  # Disable rootless mode so containers run as root but are accessible by docker group
  virtualisation.docker.rootless.enable = lib.mkForce false;
  virtualisation.docker.rootless.setSocketVariable = lib.mkForce false;

  # Ensure docker socket has correct permissions for group access
  systemd.services.docker.serviceConfig.ExecStartPost = [
    "${pkgs.coreutils}/bin/chmod 0660 /var/run/docker.sock"
  ];

  virtualisation.oci-containers.containers = {
    # -------------------------------------------------------------------------
    # traefik  (uses a secret file for the Cloudflare token)
    # -------------------------------------------------------------------------
    traefik = {
      image = "traefik:latest";
      autoStart = true;

      autoRemoveOnStop = false; # prevent implicit --rm
      extraOptions = ["--network=docker-network" "--ip=172.18.0.2"];

      ports = [
        "443:443"
        "80:80"
        "8085:8080" # Traefik dashboard
      ];

      volumes = [
        "/mnt/docker-data/volumes/traefik:/etc/traefik:rw"
        "/var/run/docker.sock:/var/run/docker.sock:rw"
      ];

      environmentFiles = [
        "/run/secrets/traefikENV"
      ];

      environment = {
        # Keys with dots must be quoted to be valid Nix attribute names
        "traefik.http.routers.api.rule" = "Host(`traefik.yakweide.de`)";
        "traefik.http.routers.api.entryPoints" = "https";
        "traefik.http.routers.api.service" = "api@internal";
        "traefik.enable" = "true";
      };
    };

    # -------------------------------------------------------------------------
    # portainer
    # -------------------------------------------------------------------------
    portainer = {
      image = "portainer/portainer-ce:latest"; # Or use :lts for stability
      autoStart = true;

      autoRemoveOnStop = false; # prevent implicit --rm
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

    # ----------------------------------------------------------
    # minecraft-server (Paper 1.21.x)
    # ----------------------------------------------------------
    minecraft-server = {
      image = "itzg/minecraft-server:latest";
      autoStart = true;
      autoRemoveOnStop = false;
      extraOptions = ["--network=docker-network" "--ip=172.18.0.6"];

      ports = ["25565:25565"];

      volumes = [
        "/mnt/docker-data/volumes/mainminecraft:/data:rw"
      ];

      environment = {
        EULA = "TRUE";
        VERSION = "LATEST";
        MEMORY = "12G";
        ENABLE_RCON = "false";
      };
    };
  };
}
