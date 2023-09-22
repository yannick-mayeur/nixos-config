# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      <nixos-hardware/hardkernel/odroid-h3>
      ./hardware-configuration.nix
    ];

  powerManagement.cpuFreqGovernor = "performance";

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/mnt/storage" =
    { device = "/dev/disk/by-uuid/a2c97b53-e421-4db7-a424-c57356e1e14c";
      fsType = "ext4";
    };

  systemd.tmpfiles.rules =
  [ # Set the permissions and the martyflix group to folders used by *arr apps
    "d /mnt/storage/media-server 0770 - martyflix - -"
    "d /mnt/storage/media-server/media/movies 0770 - martyflix - -"
    "d /mnt/storage/media-server/media/tv_shows 0770 - martyflix - -"
    "Z /mnt/storage/media-server 0770 - martyflix - -"
  ];

  networking = {
    hostName = "server";
    enableIPv6 = false;
    defaultGateway = "192.168.1.1";
    interfaces = {
      enp1s0 = {
        ipv4.addresses = [{
          address = "192.168.1.3";
          prefixLength = 24;
        }];
      };
      enp2s0 = {
        ipv4.addresses = [{
          address = "192.168.1.3";
          prefixLength = 24;
        }];
      };
    };
  };

  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "fr";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "fr";

  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" ];
    };
  };

  users.groups.martyflix = { };
  users.users.yannick = {
    isNormalUser = true;
    description = "yannick";
    extraGroups = [ "networkmanager" "wheel" "martyflix" ];
    shell = pkgs.zsh;
    useDefaultShell = true;
    packages = with pkgs; [];
  };

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
 
  services.code-server = {
    enable = true;
    host = "localhost";
    auth = "none";
  };


  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # iHD
      vaapiIntel # i965
      intel-compute-runtime # intel-opencl-icd equivalent of ubuntu
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  environment.systemPackages = with pkgs; [
    htop
    bat
    ripgrep
    zoxide
    fzf
    jq
    wget
    dig

    tailscale # added here to have the tailscale command
  ];

  virtualisation.docker.enable = true;

  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      safe.directory = "/etc/nixos";
      user = {
        name = "Yannick Mayeur";
        email = "yannick.mayeur@proton.me";
      };
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    configure = {
      customRC = ''
        set number
      '';
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [ vim-nix ];
      };
    };
  };

  services.adguardhome = {
    enable = true;
    allowDHCP = true;
    settings = {
      http.address = "0.0.0.0:8080";
      dhcp = {
        enable = true;
        interface_name = "enp2s0";
        dhcpv4 = {
          gateway_ip = "192.168.1.1";
          subnet_mask = "255.255.255.0";
          range_start = "192.168.1.2";
          range_end = "192.168.1.150";
        };
      };
      tls = {
        enabled = true;
        force_https = false;
        port_https = 0;
        allow_unencrypted_doh = true;
      };
    };
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud27;
    hostName = "localhost";
    https = true;
    database.createLocally = true;
    config = {
      dbtype = "pgsql";
      extraTrustedDomains = [ "localhost" "nextcloud.yannickm.fr" ];
      trustedProxies = [ "localhost" ];
      adminpassFile = "/etc/nixos/secrets/nextcloud-admin-password";
    };
  };
  # Nginx is used by nextcloud on port 80 by default. I'm using traefik so I change the default listening port here.
  services.nginx.virtualHosts."localhost".listen = [ { addr = "127.0.0.1"; port = 8081; } ];

  services.jellyfin = {
    enable = true;
    group = "martyflix";
  };
  users.users.jellyfin.extraGroups =
    [ # Add render group to be able to write to /dev/dri
      "render"
    ];

  services.jellyseerr = {
    enable = true;
    port = 5055;
  };

  services.authelia.instances.main = {
    enable = true;
    secrets.storageEncryptionKeyFile = "/etc/nixos/secrets/authelia/storage_encryption_key";
    secrets.jwtSecretFile = "/etc/nixos/secrets/authelia/jwt_secret";
    settings.server.host = "localhost";
    settings.server.port = 9092;
    settings = {
      access_control = {
        default_policy = "deny";
        rules = [
          { domain = "prowlarr.yannickm.fr"; resources = [ "^/[0-9]?/download([/?].*)?$" ]; policy = "bypass"; }
          { domain = "*.yannickm.fr"; resources = [ "^(/[0-9])?/api([/?].*)?$" ]; policy = "bypass"; }
          { domain = "*.yannickm.fr"; policy = "one_factor"; }
        ];
      };
      session.domain = "yannickm.fr";
      storage.local.path = "/var/lib/authelia-main/config/db.sqlite3";
      notifier.filesystem.filename = "/var/lib/authelia-main/config/notification.txt";
      authentication_backend = {
        file.path = "/var/lib/authelia-main/config/users_database.yml";
      };
    };
  };
  
  services.tiddlywiki = {
    enable = true;
    listenOptions.port = 3456;
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
    backend = "docker";

    containers."media-server_torrent" = {
      image = "haugene/transmission-openvpn:5.0.2";
      volumes = [
        "/var/lib/media-server_torrent/config:/config"
        "/mnt/storage/media-server/transmission:/data"
      ];
      ports = [ "9091:9091" ];
      environmentFiles = [ "/etc/nixos/secrets/media-server_torrent.env" ];
      extraOptions = [
        "--cap-add=NET_ADMIN"
      ];
      autoStart = true;
    };

    containers."librespeed" = {
      image = "lscr.io/linuxserver/librespeed:latest";
      volumes = [
        "/var/lib/librespeed/config:/config"
      ];
      ports = [ "6789:80" ];
      environmentFiles = [ "/etc/nixos/secrets/librespeed.env" ];
      environment = {
        PUID = "1000";
        PGID = "100";
        TZ = "Europe/Paris";
      };
      autoStart = true;
    };
  };
  
  services.traefik = {
    enable = true;
    environmentFiles = [ "/etc/nixos/secrets/traefik.env" ];
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
          authelia-basic = {
            forwardAuth = {
              address = "http://localhost:9092/api/verify?auth=basic";
              trustForwardHeader = "true";
              authResponseHeaders = [
                "Remote-User"
                "Remote-Groups"
                "Remote-Email"
                "Remote-Name"
              ];
            };
          };
          authelia = {
            forwardAuth = {
              address = "http://localhost:9092/api/verify?rd=https://auth.yannickm.fr/";
              trustForwardHeader = "true";
              authResponseHeaders = [
                "Remote-User"
                "Remote-Groups"
                "Remote-Email"
                "Remote-Name"
              ];
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
          authelia = {
            rule = "Host(`auth.yannickm.fr`)";
            service = "authelia";
            entrypoints = [ "web" "websecure" ];
          };
          adguard = {
            rule = "Host(`adguard.yannickm.fr`)";
            service = "adguard";
            entrypoints = [ "web" "websecure" ];
            middlewares = [ "authelia" ];
          };
          speed = {
            rule = "Host(`speed.yannickm.fr`)";
            service = "speed";
            entrypoints = [ "web" "websecure" ];
          };
          nextcloud = {
            rule = "Host(`nextcloud.yannickm.fr`)";
            service = "nextcloud";
            entrypoints = [ "web" "websecure" ];
          };
          immich = {
            rule = "Host(`immich.yannickm.fr`)";
            service = "immich";
            entrypoints = [ "web" "websecure" ];
          };
          code = {
            rule = "Host(`code.yannickm.fr`)";
            service = "code";
            entrypoints = [ "web" "websecure" ];
            middlewares = [ "authelia" ];
          };
          torrent-api = {
            rule = "Host(`torrent.yannickm.fr`) && PathPrefix(`/transmission/rpc`)";
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
          wiki = {
            rule = "Host(`wiki.yannickm.fr`)";
            service = "wiki";
            entrypoints = [ "web" "websecure" ];
            middlewares = [ "authelia" ];
          };
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
        };
        services = {
          authelia.loadBalancer.servers = [ { url = "http://localhost:9092"; } ];
          adguard.loadBalancer.servers = [ { url = "http://localhost:8080"; } ];
          speed.loadBalancer.servers = [ { url = "http://localhost:6789"; } ];
          nextcloud.loadBalancer.servers = [ { url = "http://localhost:8081"; } ];
          immich.loadBalancer.servers = [ { url = "http://localhost:2283"; } ];
          code.loadBalancer.servers = [ { url = "http://localhost:4444"; } ];
          wiki.loadBalancer.servers = [ { url = "http://localhost:3456"; } ];
          torrent.loadBalancer.servers = [ { url = "http://localhost:9091"; } ];
          jellyfin.loadBalancer.servers = [ { url = "http://localhost:8096"; } ];
          jellyseerr.loadBalancer.servers = [ { url = "http://localhost:5055"; } ];
          radarr.loadBalancer.servers = [ { url = "http://localhost:7878"; } ];
          sonarr.loadBalancer.servers = [ { url = "http://localhost:8989"; } ];
          prowlarr.loadBalancer.servers = [ { url = "http://localhost:9696"; } ];
          bazarr.loadBalancer.servers = [ { url = "http://localhost:6767"; } ];
        };
      };
    };
  };

  networking.firewall = {
    enable = true;
    # Adguard ports from https://github.com/AdguardTeam/AdGuardHome/wiki/Docker
    # 80/tcp for http traffic
    # 443/tcp for https traffic
    # 2283/tcp for immich
    #
    # jellyfin
    # from https://jellyfin.org/docs/general/networking/index.html
    # 1900/udp jellyfin service auto-discovery
    # 7359/udp jellyfin service auto-discovery
    allowedTCPPorts = [ 53 68 80 443 853 2283];
    allowedUDPPorts = [ 53 67 68 443 853 1900 7359 ];
  };

  services.openssh.enable = true;

  services.tailscale.enable = true;

  services.restic.backups = {
    system-local = {
      initialize = true;
      repository = "/mnt/storage/Backups/restic/server";
      paths = [
        "/home"
        "/etc/group"
        "/etc/machine-id"
        "/etc/NetworkManager/system-connections"
        "/etc/passwd"
        "/etc/subgid"
        "/root"
        "/var/backup"
        "/var/lib"
      ];
      exclude = [
        "/home/yannick/immich-app/data/encoded-video" 
        "/home/yannick/immich-app/data/thumbs" 
      ];
      passwordFile = "/etc/nixos/secrets/restic/system-backup-password";
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
      pruneOpts = [
        "--keep-daily 3"
        "--keep-weekly 2"
        "--keep-monthly 2"
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
