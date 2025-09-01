{
  modulesPath,
  config,
  pkgs,
  inputs,
  home-manager,
  lib,
  users,
  ...
}: {
  # Import the common configuration shared across all machines
  imports = [
    ../common/after_installer.nix
    ./rpi-hardware-configuration.nix
    ../common/common.nix
    ../packages/system-packages.nix
    ../packages/dependencies.nix
    (import ../common/home-manager.nix {
      inherit config pkgs inputs home-manager li usersb;
      isDesktop = false;
      isWsl = false;
      isServer = false;
      isHomeAssistant = false;
    })
  ];

  # Fix shebangs in scripts # Try to bring this back to common/common.nix however currently it breaks a lot of things for example npm
  services.envfs.enable = true;

  hardware = {
    i2c = {
      enable = true;
    };
    bluetooth.settings = {
      General = {
        # The string that remote devices will see
        Name = "konrad-Raspberry-Pi";
        DisablePlugins = "hostname";
      };
    };
  };

  # May break stuff on arch64, but is needed for some packages
  nixpkgs.config.allowUnsupportedSystem = true;

  boot.kernelPackages = pkgs.linuxPackages_rpi4;

  # Bootloader
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.timeout = lib.mkForce 1;
  boot.loader.grub = lib.mkDefault {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = false;
    devices = ["/dev/mmcblk0"]; # MicroSD card
  };

  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // {allowMissing = true;});
    })
    (self: super: let
      stub = super.runCommandNoCC "empty" {} "mkdir -p $out";

      stripZfs = pkgsSet:
        pkgsSet
        // builtins.listToAttrs
        (map (n: {
            name = n;
            value = stub;
          })
          (builtins.filter (n: lib.hasPrefix "zfs" n)
            (builtins.attrNames pkgsSet)));
    in {
      intel-media-driver = stub;
      zfs =
        super.zfs
        // {
          package = stub;
          userspace = stub;
          kernel = stub;
        };
      zfs-kernel = stub;
      linuxPackages_rpi4 = stripZfs super.linuxPackages_rpi4;
    })
  ];

  hardware.graphics.enable = false;

  # Machine specific configurations
  environment.systemPackages = with pkgs; [
  ];
}
