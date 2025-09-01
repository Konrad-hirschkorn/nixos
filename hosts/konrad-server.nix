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
    # portainer_agent
    # -------------------------------------------------------------------------
    portainer_agent = {
      image = "portainer/agent:latest";
      autoStart = true;

      autoRemoveOnStop = false; # prevent implicit --rm
      extraOptions = ["--network=docker-network" "--ip=172.18.0.3"];

      ports = ["9001:9001"];

      volumes = [
        "/mnt/docker-data/volumes/portainer:/var/lib/docker/volumes:rw"
        "/var/run/docker.sock:/var/run/docker.sock:rw"
      ];
      # No environment values needed for the agent
    };

    # --------------------------------------------------------------------------
    # yakweide-discord-bot
    # --------------------------------------------------------------------------
    yakweide-discord-bot = {
      image = "ghcr.io/yakweide/yakweide-discord-bot:latest";
      autoStart = true;

      autoRemoveOnStop = false; # prevent implicit --rm
      extraOptions = ["--network=docker-network" "--ip=172.18.0.4"];

      volumes = [
        "/mnt/docker-data/volumes/yakweide-discord-bot:/app/:rw"
      ];

      environmentFiles = [
        "/run/secrets/yakweideENV"
      ];
    };

    # --------------------------------------------------------------------------
    # vaultwarden
    # --------------------------------------------------------------------------
    vaultwarden = {
      image = "vaultwarden/server:latest";
      autoStart = true;

      autoRemoveOnStop = false; # prevent implicit --rm
      extraOptions = ["--network=docker-network" "--ip=172.18.0.5"];

      ports = [
        "4743:4743" # hostPort:containerPort
      ];

      volumes = [
        "/mnt/docker-data/volumes/vaultwarden:/data:rw"
      ];

      environmentFiles = [
        "/run/secrets/vaultwardenEnv"
      ];

      environment = {
        SIGNUPS_ALLOWED = "false";
        INVITATIONS_ALLOWED = "true";

        ROCKET_PROFILE = "release";
        ROCKET_ADDRESS = "0.0.0.0";
        ROCKET_PORT = "4743";

        DEBIAN_FRONTEND = "noninteractive";
      };
    };

    # ----------------------------------------------------------
    # minecraft-server (Paper 1.21.x)
    # ----------------------------------------------------------
    #minecraft-server = {
    #  image = "openjdk:21-jdk-slim";
    #  autoStart = true;
    #  autoRemoveOnStop = false;
    #  extraOptions = ["--network=docker-network" "--ip=172.18.0.6"];

    #  ports = ["25565:25565"];

    #  volumes = [
    #      "/mnt/docker-data/volumes/minecraft:/data:rw"
    #    ];

    #  workdir = "/data"; # Where paper.jar lives
    #  cmd = [
    #    "java"
    #    "-Xms1G" # minimum heap
    #    "-Xmx3G" # maximum heap
    #    "-jar"
    #    "paper.jar"
    #    "nogui"
    #  ];

    #  environment = {EULA = "TRUE";}; # Accept Mojang EULA
    # };

    immich-server = {
      image = "ghcr.io/immich-app/immich-server:release";
      autoStart = true;

      autoRemoveOnStop = false; # prevent implicit --rm
      extraOptions = ["--network=docker-network" "--ip=172.18.0.8"];

      ports = [
        "2283:2283"
      ];

      volumes = [
        "/mnt/docker-data/volumes/immich/upload_location:/usr/src/app/upload:rw"
        "/etc/localtime:/etc/localtime:ro"
      ];

      environmentFiles = [
        "/run/secrets/immichENV"
      ];

      environment = {
        "DB_HOSTNAME" = "immich_postgres";
      };
    };

    immich-machine-learning = {
      image = "ghcr.io/immich-app/immich-machine-learning:release";
      autoStart = true;

      autoRemoveOnStop = false; # prevent implicit --rm
      extraOptions = ["--network=docker-network" "--ip=172.18.0.9"];

      volumes = [
        "/mnt/docker-data/volumes/immich/model-cache:/cache:rw"
      ];

      environmentFiles = [
        "/run/secrets/immichENV"
      ];

      environment = {
      };
    };

    redis = {
      image = "docker.io/valkey/valkey:8-bookworm@sha256:ff21bc0f8194dc9c105b769aeabf9585fea6a8ed649c0781caeac5cb3c247884";
      autoStart = true;

      volumes = [
        "/mnt/docker-data/volumes/redis:/data:rw"
      ];

      autoRemoveOnStop = false; # prevent implicit --rm
      extraOptions = ["--network=docker-network" "--ip=172.18.0.10"];
    };

    immich_postgres = {
      image = "ghcr.io/immich-app/postgres:14-vectorchord0.3.0-pgvectors0.2.0@sha256:fa4f6e0971f454cd95fec5a9aaed2ed93d8f46725cc6bc61e0698e97dba96da1";
      autoStart = true;

      autoRemoveOnStop = false; # prevent implicit --rm
      extraOptions = ["--network=docker-network" "--ip=172.18.0.11"];

      volumes = [
        "/mnt/docker-data/volumes/immich/database:/var/lib/postgresql/data:rw"
      ];

      environmentFiles = [
        "/run/secrets/immichENV"
      ];

      environment = {
        "POSTGRES_INITDB_ARGS" = "--data-checksums";
      };
    };

    # -------------------------------------------------------------------------
    # librechat-mongodb
    # -------------------------------------------------------------------------
    librechat-mongodb = {
      image = "mongo:6";
      autoStart = true;

      autoRemoveOnStop = false; # prevent implicit --rm
      extraOptions = ["--network=docker-network" "--ip=172.18.0.12"];

      volumes = [
        "/mnt/docker-data/volumes/librechat-mongodb:/data/db:rw"
      ];

      cmd = ["--quiet"];
    };

    # -------------------------------------------------------------------------
    # librechat-meilisearch
    # -------------------------------------------------------------------------
    librechat-meilisearch = {
      image = "getmeili/meilisearch:v1.9";
      autoStart = true;

      autoRemoveOnStop = false; # prevent implicit --rm
      extraOptions = ["--network=docker-network" "--ip=172.18.0.13"];

      volumes = [
        "/mnt/docker-data/volumes/librechat-meilisearch:/meili_data:rw"
      ];

      environmentFiles = [
        "/run/secrets/librechatENV"
      ];

      environment = {
        MEILI_ENV = "production";
      };
    };

    # -------------------------------------------------------------------------
    # librechat-api
    # -------------------------------------------------------------------------
    librechat-api = {
      image = "ghcr.io/danny-avila/librechat:latest";
      autoStart = true;

      autoRemoveOnStop = false; # prevent implicit --rm
      extraOptions = ["--network=docker-network" "--ip=172.18.0.14"];

      ports = [
        "3080:3080"
      ];

      environmentFiles = [
        "/run/secrets/librechatENV"
      ];

      volumes = [
        "/mnt/docker-data/volumes/librechat-api/librechat.yaml:/app/librechat.yaml:rw"
      ];

      environment = {
        PORT = "3080";
        MONGO_URI = "mongodb://librechat-mongodb:27017/LibreChat";
        MEILI_HOST = "http://librechat-meilisearch:7700";
        ALLOW_REGISTRATION = "false";
        # Basic Model Configuration
        OPENAI_MODELS = "o4-mini,o3,gpt-4.1-nano";
        GOOGLE_MODELS = "gemini-2.5-pro,gemini-2.5-flash,gemini-2.5-flash-lite";
      };
    };

    # -------------------------------------------------------------------------
    # mcp-server-host
    # -------------------------------------------------------------------------
    mcp-server-host = {
      image = "ghcr.io/timlisemer/mcp-server-host/mcp-server-host-linux-amd64:latest";
      autoStart = true;

      autoRemoveOnStop = false; # prevent implicit --rm
      extraOptions = ["--network=docker-network" "--ip=172.18.0.15"];

      volumes = [
        "/mnt/docker-data/volumes/mcp-server-host/workspace:/workspace:rw"
        "/mnt/docker-data/volumes/mcp-server-host/data:/app/data:rw"
        "/mnt/docker-data/volumes/mcp-server-host/logs:/var/log:rw"
        "/mnt/docker-data/volumes/mcp-server-host/config:/app/config:ro"
      ];

      environment = {
        LOG_LEVEL = "info";
        WORKSPACE_PATH = "/workspace";
        MCP_SERVERS_CONFIG = "/app/config/servers.json";
      };
    };
  };

  system.activationScripts.copyLibrechatYaml = lib.stringAfter ["var"] ''
    mkdir -p /mnt/docker-data/volumes/librechat-api
    cp ${./../files/librechat.yaml} /mnt/docker-data/volumes/librechat-api/librechat.yaml
    chmod 644 /mnt/docker-data/volumes/librechat-api/librechat.yaml
  '';

  system.activationScripts.copyMcpServerConfig = lib.stringAfter ["var"] ''
    mkdir -p /mnt/docker-data/volumes/mcp-server-host/config
    cp ${./../files/mcp-server-host/servers.json} /mnt/docker-data/volumes/mcp-server-host/config/servers.json
    chmod 644 /mnt/docker-data/volumes/mcp-server-host/config/servers.json
  '';
}
