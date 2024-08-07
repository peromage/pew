{ config, lib, ... }:

let
  cfg = config.pix.services.power;

  options = with lib; {
    enable = mkEnableOption "power governor";

    profile = mkOption {
      type = types.enum [ "ondemand" "powersave" "performance" ];
      default = "ondemand";
      description = "Default power governor profile.";
    };
  };

in {
  options.pix.services.power = options;

  config = lib.mkIf cfg.enable {
    powerManagement.cpuFreqGovernor = cfg.profile;
  };
}
