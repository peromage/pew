{ config, pix, pkgs, lib, lanzaboote, ... }:

let
  libpix = pix.lib;

  cfg = config.pix.services.boot;

  options = with lib; {
    enabled = mkOption {
      type = with types; nullOr (enum [ "systemd-boot" "grub" "secure-boot"]);
      default = "systemd-boot";
      description = ''Default boot loader mode.

      If this is set to null no boot loader will be configured.

      The option `secure-boot' option implemented by `lanzaboote' which implies
      systemd-boot.

      Note: When installing the system for the first time, `systemd-boot' or
      `grub' should be used and switch to `secure-boot' after.  The steps are
      as follow:

      1. Run: sudo nix run nixpkgs#sbctl create-keys
      2. Switch to the option `secure-boot', build and reboot.
      3. Run: sudo nix run nixpkgs#sbctl verify
      4. Reboot and set BIOS in setup mode (Erase all secure boot settings).
      5. Run: sudo nix run nixpkgs#sbctl enroll-keys -- --microsoft
      6. Run: bootctl status
      '';
    };

    grubDevice = with lib; mkOption {
      type = types.str;
      default = "";
      description = "Same option `boot.loader.grub.device'.";
    };
  };

in {
  imports = [ lanzaboote.nixosModules.lanzaboote ];
  options.pix.services.boot = options;

  config = with lib; libpix.mkMergeIf [
    {
      cond = "systemd-boot" == cfg.enabled;
      as = {
        boot = {
          bootspec.enable = true;
          loader = {
            grub.enable = mkForce false;
            systemd-boot.enable = mkForce true;
            efi.canTouchEfiVariables = false;
          };
        };
      };
    }

    {
      cond = "grub" == cfg.enabled;
      as = {
        boot = {
          bootspec.enable = true;
          loader = {
            grub = {
              enable = mkForce true;
              device = cfg.grubDevice;
            };
            systemd-boot.enable = mkForce false;
            efi.canTouchEfiVariables = false;
          };
        };
      };
    }

    {
      cond = "secure-boot" == cfg.enabled;
      as = {
        boot = {
          bootspec.enable = true;
          lanzaboote = {
            enable = true;
            pkiBundle = "/etc/secureboot";
          };

          loader = {
            grub.enable = mkForce false;
            systemd-boot.enable = mkForce false;
            efi.canTouchEfiVariables = false;
          };
        };

        environment.systemPackages = with pkgs; [
          sbctl
        ];
      };
    }
  ];
}
