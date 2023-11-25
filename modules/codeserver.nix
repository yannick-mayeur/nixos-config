{ config, pkgs, ... }:

{
  nixpkgs.config.permittedInsecurePackages =
    [ # Used by code server
    "nodejs-16.20.2"
  ];

  users.users.code-server = {
    isNormalUser = true;
    createHome = true;
    extraGroups = [ ];
    shell = pkgs.zsh;
    packages = with pkgs; [];
  };

  services.openvscode-server = {
    enable = true;
    host = "localhost";
    port = 4444;
    user = "code-server";
    withoutConnectionToken = true;
  };

  services.traefik.dynamicConfigOptions.http = {
    routers = {
      code = {
        rule = "Host(`code.yannickm.fr`)";
        service = "code";
        entrypoints = [ "web" "websecure" ];
        middlewares = [ "authelia" ];
      };
    };
    services = {
      code.loadBalancer.servers = [ { url = "http://localhost:4444"; } ];
    };
  };
}
