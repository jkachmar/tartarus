{ config, lib, ... }:
let
  cfg = config.services.smartd;
in
{
  options.services.smartd.defaults = {
    shared = lib.mkOption {
      description = "a list of options to be shared among 'smartd' configurations";
      default = [ ];
      type = lib.types.listOf lib.types.str;
    };
  };
  config.services.smartd = {
    autodetect = true;
    # Default to saving the attribute logs & state information to
    # `/var/log/smartd` instead of the default `/var/lib/smartmontools`.
    extraOptions = lib.mkDefault [
      "--attributelog"
      "/var/log/smartd/"
      "--savestates"
      "/var/log/smartd/"
    ];
    # Use shared 'smartd' options + temperature tracking that assumes HDDs.
    #
    # NVMe drives should get their own explicit device config.
    defaults.autodetected = lib.concatStringsSep " " (
      cfg.defaults.shared
      ++ [
        # Drive temperature -- track,log,alert
        #
        # That is: don't track incremental temperature changes, log when
        # temperatures exceed 40 C, alert when temperatures exceed 45 C.
        "-W 0,40,45"
      ]
    );
    defaults.shared = [
      # Enables the following directives:
      #   -H -- check health status of the disk
      #   -f -- check for 'failure' of any Usage Attributes
      #   -t -- report when Prefail or Usage Attributes change between tests
      #   -l error -- report when errors increase over time
      #   -l selftest -- report when Self-Test failures increase over time
      #   -l selfteststs -- report if Self-Test status changes between tests
      #
      # cf. https://man.archlinux.org/man/smartd.conf.5.en#a
      "-a"
      # Enables or disables SMART Automatic Offline Testing when smartd starts up;
      # valid arguments to this Directive are 'on' and 'off'.
      "-o on"
      # Ensure device vendor-specific attribute autosave is enabled.
      "-S on"
      # Run tests at scheduled times according to the pattern: T/MM/DD/d/HH
      #
      # T  -- test type: S = short, O = offline, L = extended, c = selective*
      # MM -- month of the year (Gregorian) as two decimal digits (01 - 12)
      # DD -- day of the month as two decimal digits (01 - 31)
      # d  -- day of the week as one decimal digit (1 = Monday, 7 = Sunday)
      # HH -- hour of the day as two decimal digits (00 - 23)
      #
      # cf.
      #   https://man.archlinux.org/man/smartd.conf.5.en#s -- scheduling
      #   https://man.archlinux.org/man/smartctl.8#l -- test types
      #
      # - Short - daily at midnight
      # - Extended - 15th of each month (ZFS scrubs are on the 1st) at 2 AM
      #
      # TODO: Look into selective tests, which can be run on a range of LBAs
      # and then "continued" via `smartd`. For example, a 16 TB extended test
      # could be run over several days in 4 TB increments.
      "-s (S/../.././00|L/../15/./02)"
    ];
  };
}
