{ config, pkgs, ... }:

{
  services.tiddlywiki = {
    enable = true;
    listenOptions.port = 3456;
  };

  services.traefik.dynamicConfigOptions.http = {
    routers = {
      wiki = {
        rule = "Host(`wiki.yannickm.fr`)";
        service = "wiki";
        entrypoints = [ "web" "websecure" ];
        middlewares = [ "authelia" ];
      };
    };
    services = {
      wiki.loadBalancer.servers = [{ url = "http://localhost:3456"; }];
    };
  };
}
