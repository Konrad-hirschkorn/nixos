{
  config,
  pkgs,
  inputs,
  home-manager,
  lib,
  users,
  hostName,
  hostIps,
  ...
}: let
  dockerBin = "${pkgs.docker}/bin/docker";
in {
  # imports
  imports = [
    home-manager.nixosModules.home-manager
  ];

  nix.settings = {
    substituters = [
      "file:///nix/store?trusted=1"
      "https://cache.nixos.org?priority=40"
      "https://nixos-raspberrypi.cachix.org?priority=30"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];

    trusted-users = [ "root" "@wheel" ];
  };

  nix.extraOptions = ''
    !include /run/secrets-rendered/nix-extra.conf
  '';

  environment.variables = {
    RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
    MOZ_DISABLE_RDD_SANDBOX = "1";
    MUTTER_DEBUG_KMS_THREAD_TYPE = "user";
    NODE_OPTIONS = "--max-old-space-size=4096";
    SGX_ENCLAVE_SIZE = "4G";
    RUST_MIN_STACK = "268435456";
    QT_QPA_PLATFORM = "wayland";
    NIXPKGS_ALLOW_UNFREE = "1";
    WEBKIT_DISABLE_DMABUF_RENDERER = "1";
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
    BLESH_PATH = "${pkgs.blesh}/share/blesh";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.download-buffer-size = 524288000;

  # HIER: unsicheres Paket erlauben


  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # … alles Weitere aus deiner Datei unverändert …

  system.stateVersion = "25.05";
}
