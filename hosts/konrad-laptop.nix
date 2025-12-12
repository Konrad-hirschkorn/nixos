{ disks, config, pkgs, ... }:

{
  imports = [
    (import ../common/disko.nix { inherit disks; })
    ./desktop-only-imports.nix
    ./konrad-laptop-hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  hardware = {
    i2c.enable = true;

    bluetooth.settings.General = {
      Name = "konrad-Laptop";
      DisablePlugins = "hostname";
    };
  };

  nixpkgs.config.permittedInsecurePackages = [
    "electron-36.9.5"
  ];
}
