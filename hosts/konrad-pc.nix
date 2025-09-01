{
  disks,
  config,
  pkgs,
  ...
}: {
  # Import the common configuration shared across all machines
  imports = [
    (import ../common/disko.nix {inherit disks;})
    ./desktop-only-imports.nix
    ./konrad-pc-hardware-configuration.nix
    ../common/nvidia.nix
  ];

  # Machine specific configurations

  boot = {
    kernelParams = ["acpi_enforce_resources=lax"];
    kernelModules = ["i2c-dev" "i2c-piix4"];
  };

  hardware = {
    i2c = {
      enable = true;
    };
    bluetooth.settings = {
      General = {
        # The string that remote devices will see
        Name = "konrad-PC";
        DisablePlugins = "hostname";
      };
    };
  };

  # Portainer Container
  virtualisation.oci-containers.containers = {
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
  };

  # services.udev.extraRules = builtins.readFile ../files/OpenRGB/60-openrgb.rules;

  environment.systemPackages = with pkgs; [openrgb-with-all-plugins];

  services.hardware.openrgb.enable = true;
  systemd.user.services.openrgb = {
    description = "OpenRGB";
    wantedBy = ["default.target" "graphical-session.target"];
    partOf = ["graphical-session.target"];
    serviceConfig = {
      # ExecStart = "${pkgs.openrgb-with-all-plugins}/bin/openrgb --startminimized --profile 'On'";
      # ExecStartPre = "${pkgs.coreutils}/bin/sleep 10";
      ExecStart = "/bin/openrgb --startminimized --profile 'On'";
      Restart = "on-failure";
      RestartSec = "5s";
      StartLimitIntervalSec = "10s";
      StartLimitBurst = "10";
      After = ["graphical-session.target" "network-online.target"];
    };
  };
}
