{ config, pkgs, ... }:

{
  services.adguardhome = {
    enable = true;
    allowDHCP = true;
    settings = {
      http.address = "0.0.0.0:8080";
      dhcp = {
        enable = true;
        interface_name = "enp1s0";
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

  services.traefik.dynamicConfigOptions.http = {
    routers = {
      adguard = {
        rule = "Host(`adguard.yannickm.fr`)";
        service = "adguard";
        entrypoints = [ "web" "websecure" ];
        middlewares = [ "authelia" ];
      };
    };
    services = {
      adguard.loadBalancer.servers = [{ url = "http://localhost:8080"; }];
    };
  };

  networking.firewall = {
    # Adguard ports from https://github.com/AdguardTeam/AdGuardHome/wiki/Docker
    allowedTCPPorts = [ 53 68 443 853 ];
    allowedUDPPorts = [ 53 67 68 443 853 ];
  };
}
