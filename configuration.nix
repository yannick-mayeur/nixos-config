# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./modules/adguard.nix
      ./modules/authelia.nix
      ./modules/codeserver.nix
      ./modules/jellyfin.nix
      ./modules/librespeed.nix
      ./modules/nextcloud.nix
      ./modules/tiddlywiki.nix
      ./modules/traefik.nix
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
    useDHCP = false;
    enableIPv6 = false;
    defaultGateway = "192.168.1.1";
    interfaces = {
      enp1s0 = {
        ipv4.addresses = [{
          address = "192.168.1.3";
          prefixLength = 24;
        }];
      };
    };
    firewall = {
      enable = true;
      # 2283/tcp for immich
      allowedTCPPorts = [ 2283 ];
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

  users.groups.martyflix = { };
  users.users.yannick = {
    isNormalUser = true;
    description = "yannick";
    extraGroups = [ "networkmanager" "wheel" "martyflix" ];
    shell = pkgs.zsh;
    useDefaultShell = true;
    packages = with pkgs; [];
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

  virtualisation = {
    docker.enable = true;
    oci-containers.backend = "docker";
  };

  environment.systemPackages = with pkgs; [
    git # Should be kept as it is used by flakes
    htop
    bat
    ripgrep
    zoxide
    fzf
    jq
    wget
    dig
    yazi
    openai-whisper

    tailscale # added here to have the tailscale command
  ];

  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" ];
    };
  };

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
      passwordFile = "/etc/nixos-secrets/restic/system-backup-password";
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

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
