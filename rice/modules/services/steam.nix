{ config, lib, pkgs, rice, ... }:

let
  librice = rice.lib;

  cfg = config.rice.services.steam;

  options = with lib; {
    enable = mkEnableOption "Steam";
    openFirewall = {
      remotePlay = mkEnableOption "Steam remote play ports";
      sourceServer = mkEnableOption "Steam Source server ports";
    };
  };

  ricedSteam = pkgs.steam.override {
    extraPkgs = spkgs: with spkgs; [
      xorg.libXcursor
      xorg.libXi
      xorg.libXinerama
      xorg.libXScrnSaver
      libpng
      libpulseaudio
      libvorbis
      stdenv.cc.cc.lib
      libkrb5
      keyutils
      steamPackages.steamcmd
      steamPackages.steam-runtime
      wqy_zenhei
      wqy_microhei
    ];
  };

in {
  options.rice.services.steam = options;

  config = librice.mkMergeIf [
    {
      cond = cfg.enable;
      as = {
        hardware.steam-hardware.enable = true;

        programs.steam = {
          enable = true;
          gamescopeSession.enable = true;
          package = ricedSteam;
        };

        environment.systemPackages = with pkgs; [
          steam-run
          protonup-qt
        ];
      };
    }

    {
      cond = cfg.enable && cfg.openFirewall.remotePlay;
      as = {
        programs.steam.remotePlay.openFirewall = true;
      };
    }

    {
      cond = cfg.enable && cfg.openFirewall.sourceServer;
      as = {
        programs.steam.dedicatedServer.openFirewall = true;
      };
    }
  ];
}
