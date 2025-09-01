{
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
    inputs.nixos-wsl.nixosModules.default
    ../common/common.nix
    ../common/after_installer.nix
    ../packages/system-packages.nix
    ../packages/dependencies.nix
    (import ../common/home-manager.nix {
      inherit config pkgs inputs home-manager lib users;
      isDesktop = false;
      isWsl = true;
      isServer = false;
      isHomeAssistant = false;
    })
  ];

  # Machine specific configurations
  wsl.enable = true;
  wsl.defaultUser = "konrad";
  wsl.docker-desktop.enable = true;
  environment.variables.WSL = "1";
  wsl.wslConf.network.generateHosts = false;
  wsl.wslConf.interop = {
    enabled = true;
    appendWindowsPath = true; # keeps the Windows PATH additions
  };

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };

  # docker context create nixos-wsl --docker "host=tcp://localhost:2375"
  # docker context use nixos-wsl
  virtualisation.docker.daemon.settings = {
    # expose for Windows; remove if you only need CLI inside WSL
    "hosts" = [
      "unix:///var/run/docker.sock"
      "tcp://0.0.0.0:2375"
    ];
  };

  environment.shellAliases = {
    code = lib.mkForce "wslcode";
  };

  environment.systemPackages = with pkgs;
    lib.mkAfter [
      wslu

      (pkgs.writeShellScriptBin "wslcode" ''
        #! /usr/bin/env bash
        set -euo pipefail

        if [[ "''${WSL:-0}" = "0" ]]; then
          echo "This function is only available from within a wsl environment"
          exit 1
        fi

        win_user="$(wslvar USERNAME | tr -d '\r')"
        vscode="/mnt/c/Users/''${win_user}/AppData/Local/Programs/Microsoft VS Code/Code.exe"
        if [[ ! -x "$vscode" ]]; then
          echo "wslcode: VS Code not found at $vscode" >&2
          exit 1
        fi

        distro="''${WSL_DISTRO_NAME:-$(wslvar WSL_DISTRO_NAME | tr -d '\r')}"
        if [[ $# -eq 0 ]]; then
          set -- .
        fi

        args=()
        for p in "$@"; do
          abs="$(realpath "$p")"
          uri="vscode-remote://wsl+''${distro}''${abs}"
          if [[ -d "$abs" ]]; then
            args+=(--folder-uri "$uri")
          else
            args+=(--file-uri "$uri")
          fi
        done

        (
          nohup "$vscode" "''${args[@]}" >/dev/null 2>&1 &
          disown
        ) >/dev/null 2>&1

        exit 0
      '')
    ];
}
