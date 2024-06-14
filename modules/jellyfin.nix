{ config, pkgs, ... }:

{
  services.jellyfin = {
    enable = true;
    group = "martyflix";
  };
  users.users.jellyfin.extraGroups =
    [
      # Add render group to be able to write to /dev/dri
      "render"
    ];

  services.jellyseerr = {
    enable = true;
    port = 5055;
  };

  services.prowlarr.enable = true;

  services.radarr = {
    enable = true;
    group = "martyflix";
  };

  services.sonarr = {
    enable = true;
    group = "martyflix";
  };

  services.bazarr = {
    enable = true;
    group = "martyflix";
  };

  virtualisation.oci-containers = {
    containers."flaresolverr" = {
      image = "flaresolverr/flaresolverr";
      ports = [ "8191:8191" ];
      autoStart = true;
    };

    containers."media-server_qbittorrent" = {
      image = "lscr.io/linuxserver/qbittorrent:latest";
      volumes = [
        "/mnt/storage/media-server/qbittorrent:/media-server/qbittorrent"
        "/var/lib/media-server_qbittorrent/config:/config"
      ];
      environmentFiles = [ "/etc/nixos-secrets/media-server_qbittorrent.env" ];
      extraOptions = [
        "--network=container:gluetun"
      ];
      autoStart = true;
    };

    containers."gluetun" = {
      image = "qmcgaw/gluetun";
      volumes = [
        "/var/lib/gluetun:/gluetun"
      ];
      environmentFiles = [ "/etc/nixos-secrets/gluetun.env" ];
      extraOptions = [
        "--cap-add=NET_ADMIN"
      ];
      ports = [
        "8088:8088" # qbittorrent
      ];
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers = {
      jellyfin = {
        rule = "Host(`jellyfin.yannickm.fr`)";
        service = "jellyfin";
        entrypoints = [ "web" "websecure" ];
      };
      jellyseerr = {
        rule = "Host(`jellyseerr.yannickm.fr`)";
        service = "jellyseerr";
        entrypoints = [ "web" "websecure" ];
      };
      radarr = {
        rule = "Host(`radarr.yannickm.fr`)";
        service = "radarr";
        entrypoints = [ "web" "websecure" ];
        middlewares = [ "authelia" ];
      };
      sonarr = {
        rule = "Host(`sonarr.yannickm.fr`)";
        service = "sonarr";
        entrypoints = [ "web" "websecure" ];
      };
      prowlarr = {
        rule = "Host(`prowlarr.yannickm.fr`)";
        service = "prowlarr";
        entrypoints = [ "web" "websecure" ];
        middlewares = [ "authelia" ];
      };
      bazarr = {
        rule = "Host(`bazarr.yannickm.fr`)";
        service = "bazarr";
        entrypoints = [ "web" "websecure" ];
        middlewares = [ "authelia" ];
      };
      qbittorrent-api = {
        rule = "Host(`qbittorrent-api.yannickm.fr`)";
        service = "qbittorrent";
        entrypoints = [ "web" "websecure" ];
        middlewares = [ "authelia-basic" ];
      };
      qbittorrent = {
        rule = "Host(`qbittorrent.yannickm.fr`)";
        service = "qbittorrent";
        entrypoints = [ "web" "websecure" ];
        middlewares = [ "authelia" "qb-headers" ];
      };
      flaresolverr = {
        rule = "Host(`flaresolverr.yannickm.fr`)";
        service = "flaresolverr";
        entrypoints = [ "web" "websecure" ];
        middlewares = [ "local-only" ];
      };
    };
    services = {
      jellyfin.loadBalancer.servers = [{ url = "http://localhost:8096"; }];
      jellyseerr.loadBalancer.servers = [{ url = "http://localhost:5055"; }];
      radarr.loadBalancer.servers = [{ url = "http://localhost:7878"; }];
      sonarr.loadBalancer.servers = [{ url = "http://localhost:8989"; }];
      prowlarr.loadBalancer.servers = [{ url = "http://localhost:9696"; }];
      bazarr.loadBalancer.servers = [{ url = "http://localhost:6767"; }];
      qbittorrent.loadBalancer = {
        servers = [{ url = "http://localhost:8088"; }];
        passhostheader = false;
      };
      flaresolverr.loadBalancer.servers = [{ url = "http://localhost:8191"; }];
    };
  };

  networking.firewall = {
    # jellyfin
    # from https://jellyfin.org/docs/general/networking/index.html
    # 1900/udp jellyfin service auto-discovery
    # 7359/udp jellyfin service auto-discovery
    allowedUDPPorts = [ 1900 7359 ];
  };
}
