
{ config, pkgs, ... }:

{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud27;
    hostName = "localhost";
    https = true;
    database.createLocally = true;
    configureRedis = true;
    config = {
      dbtype = "pgsql";
      extraTrustedDomains = [ "localhost" "nextcloud.yannickm.fr" ];
      trustedProxies = [ "localhost" ];
      adminpassFile = "/etc/nixos-secrets/nextcloud-admin-password";
    };
  };

  # Nginx is used by nextcloud on port 80 by default.
  # I'm using traefik so I change the default listening port here.
  services.nginx.virtualHosts."localhost".listen = [ { addr = "127.0.0.1"; port = 8081; } ];

  services.traefik.dynamicConfigOptions.http = {
    routers = {
      nextcloud = {
        rule = "Host(`nextcloud.yannickm.fr`)";
        service = "nextcloud";
        entrypoints = [ "web" "websecure" ];
      };
    };
    services = {
      nextcloud.loadBalancer.servers = [ { url = "http://localhost:8081"; } ];
    };
  };
}
