{ lib, ... }:
{
  security.acme = {
    acceptTerms = lib.mkDefault true;
    defaults = {
      email = lib.mkDefault "admin@thempire.dev";
      dnsProvider = lib.mkDefault "porkbun";
    };
  };
}
