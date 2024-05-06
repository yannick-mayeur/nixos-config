{ config, pkgs, ... }:

{
  virtualisation.oci-containers = {
    containers."librespeed" = {
      image = "lscr.io/linuxserver/librespeed:latest";
      volumes = [
        "/var/lib/librespeed/config:/config"
      ];
      ports = [ "6789:80" ];
      environmentFiles = [ "/etc/nixos-secrets/librespeed.env" ];
      environment = {
        PUID = "1000";
        PGID = "100";
        TZ = "Europe/Paris";
      };
      autoStart = true;
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers = {
      speed = {
        rule = "Host(`speed.yannickm.fr`)";
        service = "speed";
        entrypoints = [ "web" "websecure" ];
      };
    };
    services = {
      speed.loadBalancer.servers = [{ url = "http://localhost:6789"; }];
    };
  };
}
