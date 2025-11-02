{ config, lib, ... }:
let
  cfg = config.services.ddclient;
  boolToStr = bool: if bool then "YES" else "NO";
  placeholder = config.sops.placeholder;
in
{
  sops.templates."ddclient.conf".content = ''
    cache=/var/lib/ddclient/ddclient.cache
    foreground=YES
    ${lib.optionalString (cfg.use != "") "use=${cfg.use}"}
    ${lib.optionalString (cfg.use == "" && cfg.usev4 != "") "usev4=${cfg.usev4}"}
    ${lib.optionalString (cfg.use == "" && cfg.usev6 != "") "usev6=${cfg.usev6}"}
    ssl=${boolToStr cfg.ssl}
    wildcard=YES
    quiet=${boolToStr cfg.quiet}
    verbose=${boolToStr cfg.verbose}

    protocol=porkbun
    apikey=${placeholder."porkbun/apikey"}
    secretapikey=${placeholder."porkbun/secretapikey"}
    ${placeholder."porkbun/domains"}
  '';

  services.ddclient = {
    enable = true;
    interval = "3h";
    configFile = "/run/credentials/ddclient.service/ddclient.conf";
  };

  # XXX: Workaround systemd 'DynamicUser' & sops credentials.
  systemd.services.ddclient.serviceConfig.LoadCredential = "ddclient.conf:${
    config.sops.templates."ddclient.conf".path
  }";

  sops.secrets =
    lib.genAttrs
      [
        "porkbun/apikey"
        "porkbun/secretapikey"
        "porkbun/domains"
      ]
      (secret: {
        # TIL 'ddclient' supports SIGHUP
        reloadUnits = [ config.systemd.services.ddclient.name ];
      });
}
