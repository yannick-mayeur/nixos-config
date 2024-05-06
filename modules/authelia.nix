{ config, pkgs, ... }:

{
  services.authelia.instances.main = {
    enable = true;
    secrets.storageEncryptionKeyFile = "/etc/nixos-secrets/authelia/storage_encryption_key";
    secrets.jwtSecretFile = "/etc/nixos-secrets/authelia/jwt_secret";
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

  services.traefik.dynamicConfigOptions.http = {
    middlewares = {
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
      authelia = {
        rule = "Host(`auth.yannickm.fr`)";
        service = "authelia";
        entrypoints = [ "web" "websecure" ];
      };
    };
    services = {
      authelia.loadBalancer.servers = [{ url = "http://localhost:9092"; }];
    };
  };
}
