{ config, pkgs, ... }:

{
  services.traefik = {
    enable = true;
    environmentFiles = [ "/etc/nixos-secrets/traefik.env" ];
    staticConfigOptions = {
      log.level = "info";
      api.dashboard = true;
      global = {
        checknewversion = false;
        sendanonymoususage = false;
      };
      entryPoints = {
        web = {
          address = ":80";
          http.middlewares = [ "https-redirect" ];
        };
        websecure = {
          address = ":443";
          http.tls = {
            certResolver = "godaddy";
            domains = [{ main = "yannickm.fr"; sans = [ "*.yannickm.fr" ]; }];
          };
        };
      };
      certificatesResolvers = {
        godaddy = {
          acme = {
            email = "yannick.mayeur@proton.me";
            storage = "${config.services.traefik.dataDir}/acme.json";
            dnsChallenge = {
              provider = "godaddy";
              resolvers = [ "192.168.1.3" ];
            };
          };
        };
      };
    };
    dynamicConfigOptions = {
      http = {
        middlewares = {
          local-only = {
            ipWhiteList.sourceRange = [ "127.0.0.1/32" "192.168.1.0/24" ];
          };
          https-redirect = {
            redirectScheme = {
              scheme = "https";
              permanent = true;
            };
          };
        };
        routers = {
          traefik = {
            rule = "Host(`traefik.yannickm.fr`)";
            service = "api@internal";
            entrypoints = [ "web" "websecure" ];
            middlewares = [ "local-only" "authelia" ];
          };
          immich = {
            rule = "Host(`immich.yannickm.fr`)";
            service = "immich";
            entrypoints = [ "web" "websecure" ];
          };
        };
        services = {
          immich.loadBalancer.servers = [ { url = "http://localhost:2283"; } ];
        };
      };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 80 443 ];
    allowedUDPPorts = [ 80 443 ];
  };
}
