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
    containers."media-server_torrent" = {
      image = "haugene/transmission-openvpn";
      volumes = [
        "/var/lib/media-server_torrent/config:/config"
        "/mnt/storage/media-server/transmission:/data"
      ];
      ports = [ "9091:9091" ];
      environmentFiles = [ "/etc/nixos-secrets/media-server_torrent.env" ];
      extraOptions = [
        "--cap-add=NET_ADMIN"
      ];
      autoStart = true;
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
      torrent-api = {
        rule = "Host(`torrent-api.yannickm.fr`)";
        service = "torrent";
        entrypoints = [ "web" "websecure" ];
        middlewares = [ "authelia-basic" ];
      };
      torrent = {
        rule = "Host(`torrent.yannickm.fr`)";
        service = "torrent";
        entrypoints = [ "web" "websecure" ];
        middlewares = [ "authelia" ];
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
      torrent.loadBalancer.servers = [{ url = "http://localhost:9091"; }];
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
