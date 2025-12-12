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

  users.users.konrad = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    home = "/home/konrad";
  };

  hardware = {
    i2c.enable = true;

    bluetooth.settings.General = {
      Name = "konrad-Laptop";
      DisablePlugins = "hostname";
    };
  };

}
