{
  config,
  pkgs,
  inputs,
  home-manager,
  lib,
  isDesktop,
  isWsl,
  isServer,
  isHomeAssistant,
  users,
  ...
}: let
in {
  # Import the Home Manager NixOS module
  imports = [
  ];

  # NixOS system-wide home-manager configuration
  home-manager.sharedModules = [
    inputs.sops-nix.homeManagerModules.sops
    (import ./common-home-manager.nix {
      inherit config pkgs inputs home-manager lib isDesktop isWsl isServer isHomeAssistant;
    })
  ];

  # Home Manager individual user configuration
  home-manager.users = lib.mapAttrs (_name: user:
    {
      home.stateVersion = "25.05";

      programs.git = {
        enable = true;
        userName = user.gitUsername;
        userEmail = user.gitEmail;
        extraConfig = {
          init.defaultBranch = "main";
          safe.directory = ["/etc/nixos" "/tmp/NixOs"];
          pull.rebase = "true";
          push.autoSetupRemote = true;
          core.autocrlf = "input";
          core.eol = "lf";
        };
      };

      home.file = {
        ".config/hypr/hyprland.conf" = {
          source = builtins.toPath ../files/hypr/hyprland.conf;
          force = true;
        };
      };
    }
    // (lib.optionalAttrs isHomeAssistant {
      systemd.user.services.konrad-server-tunnel = {
        Unit = {
          Description = "Persistent SSH tunnel to konrad-server";
        };
        Install = {
          WantedBy = ["default.target"];
        };
        Service = {
          ExecStartPre = "${pkgs.coreutils}/bin/chmod 600 %h/.ssh/id_ed25519";
          ExecStart = "${pkgs.openssh}/bin/ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -N -i %h/.ssh/id_ed25519 -R *:8123:localhost:8123 -L 0.0.0.0:9001:konrad-server:9001 konrad@konrad-server";
          Restart = "always";
          RestartSec = "5s";
        };
      };
    }))
  users;
}
