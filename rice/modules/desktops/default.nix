{ config, lib, pkgs, rice, ... }:

let
  inherit (lib) mkEnableOption mkIf ;
  inherit (rice.lib) anyEnable callListWithArgs listDirNoDefault;

  cfg = config.rice.desktops;

  options = {
    /* The display server is actually selected by the display manager.
       See: https://discourse.nixos.org/t/enabling-x11-still-results-in-wayland/25362/2
    */
    enableWayland = mkEnableOption "Wayland display server" // { default = true; };
    enableOpenGL = mkEnableOption "OpenGL support" // { default = true; };

    env = {};
  };

  /* Additional arguments to import submodules.

     CONTRACT: Each profile declared in this set must have options:

       - enable
  */
  args = {
    mkDesktopOptions = { name }: {
      enable = mkEnableOption "desktop environment";
    };
  };

  ## Do not enable desktop settings if no desktop environment is enabled
  enableDesktopConfig = anyEnable cfg.env;

in {
  imports = callListWithArgs args (listDirNoDefault ./.);
  options.rice.desktops = options;

  config = mkIf enableDesktopConfig {
    services = {
      xserver.enable = true;
      libinput.enable = true;
    };

    programs.xwayland.enable = cfg.enableWayland;

    hardware.opengl = {
      enable = cfg.enableOpenGL;
      driSupport = true;
      driSupport32Bit = true;
    };

    environment.systemPackages = with pkgs; [
      desktop-file-utils
    ];
  };
}
