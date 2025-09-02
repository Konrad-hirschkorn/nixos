{
  config,
  pkgs,
  inputs,
  hostName,
  ...
}: {
  # sops encryption settings
  sops.defaultSopsFile = ./secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.sshKeyPaths = ["/etc/ssh/nixos_personal_sops_key"];
  # sops.age.keyFile      = "/home/konrad/.config/sops/age/keys.txt";
  # sops.age.generateKey  = true;

  #sops.secrets.github_token = {};
  sops.secrets.vaultwardenEnv = {};
  sops.secrets.traefikENV = {};
  sops.secrets.piholePWD = {};
  sops.secrets.immichENV = {};
  sops.secrets.wifiENV = {};

  # Template for nix.conf with GitHub token
  #sops.templates."nix-extra.conf" = {
  #  owner = "root";
  #  mode = "0444";
  #  content = ''
  #    access-tokens = github.com=${config.sops.placeholder.github_token}
  #  '';
  #};

  sops.secrets.openvpn_ca = {owner = "nm-openvpn";};
  sops.secrets.openvpn_extra_certs = {group = "nm-openvpn";};
  sops.secrets.openvpn_cert = {group = "nm-openvpn";};
  sops.secrets.openvpn_key = {group = "nm-openvpn";};
  sops.secrets.openvpn_ta = {group = "nm-openvpn";};
}
