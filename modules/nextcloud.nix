{ config, pkgs, ... }:

{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud29;
    hostName = "localhost";
    https = true;
    database.createLocally = true;
    configureRedis = true;
    settings = {
      trusted_domains = [ "localhost" "nextcloud.yannickm.fr" ];
      trusted_proxies = [ "127.0.0.1" ];
    };
    config = {
      dbtype = "pgsql";
      adminpassFile = "/etc/nixos-secrets/nextcloud-admin-password";
    };

    autoUpdateApps.enable = true;
    extraAppsEnable = true;
    extraApps = with config.services.nextcloud.package.packages.apps; {
      inherit contacts notes cookbook;
    };

    phpOptions."opcache.interned_strings_buffer" = "16";
  };

  # Nginx is used by nextcloud on port 80 by default.
  # I'm using traefik so I change the default listening port here.
  services.nginx.virtualHosts."localhost".listen = [{ addr = "127.0.0.1"; port = 8081; }];

  services.traefik.dynamicConfigOptions.http = {
    routers = {
      nextcloud = {
        rule = "Host(`nextcloud.yannickm.fr`)";
        service = "nextcloud";
        entrypoints = [ "web" "websecure" ];
      };
    };
    services = {
      nextcloud.loadBalancer.servers = [{ url = "http://localhost:8081"; }];
    };
  };
}
