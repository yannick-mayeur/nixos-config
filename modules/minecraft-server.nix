{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.homelab.minecraft-server;
in
{
  options.homelab.minecraft-server = {
    enable = mkEnableOption "hello service";
  };

  config = mkIf cfg.enable {
    services.minecraft-server = {
      enable = true;
      eula = true;
    };
  };
}
