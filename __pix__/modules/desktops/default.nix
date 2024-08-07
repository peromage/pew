{ config, lib, pkgs, pix, ... }:

let
  libpix = pix.lib;

  cfg = config.pix.desktops;

  options = with lib; {
    /* The display server is actually selected by the display manager.
       See: https://discourse.nixos.org/t/enabling-x11-still-results-in-wayland/25362/2
    */
    enableWayland = mkEnableOption "Wayland display server" // { default = true; };
    enableGraphicAcceleration = mkEnableOption "Graphic acceleration support" // { default = true; };

    env = {};
  };

  /* Additional arguments to import submodules.

     CONTRACT: Each profile declared in this set must have options:

       - enable
  */
  args = {
    mkDesktopOptions = { name }: {
      enable = lib.mkEnableOption "desktop environment";
    };
  };

  ## Do not enable desktop settings if no desktop environment is enabled
  enableDesktopConfig = libpix.anyEnable cfg.env;

in {
  imports = with libpix; callAll args (listDir isNotDefaultNix ./.);
  options.pix.desktops = options;

  config = lib.mkIf enableDesktopConfig {
    services = {
      xserver.enable = true;
      libinput.enable = true;
    };

    programs.xwayland.enable = cfg.enableWayland;

    hardware.graphics = {
      enable = cfg.enableGraphicAcceleration;
      enable32Bit = cfg.enableGraphicAcceleration;
    };

    environment.systemPackages = with pkgs; [
      desktop-file-utils
    ];
  };
}
