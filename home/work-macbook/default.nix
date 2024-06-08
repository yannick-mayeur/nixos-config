{ lib, pkgs, ... }:

{
  imports = [
    ../.
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "yannickmayeur";
  home.homeDirectory = "/Users/yannickmayeur";

  programs.git = {
    userEmail = lib.mkForce "ymayeur@sweep.net";
  };

  home.packages = with pkgs; [ ];

  programs.zsh.initExtra = lib.mkAfter ''
    source ~/Repos/sweep-nix-wrapper/sweep/sweep
  '';

  home.file = {
    ".yabairc".source = ../common/dotfiles/yabairc;
    ".skhdrc".source = ../common/dotfiles/skhdrc;
  };

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        option_as_alt = "OnlyLeft";
        decorations = "buttonless";
        padding.x = 5;
        padding.y = 5;
      };
      font = {
        size = 18;
        bold = {
          family = "Hack Nerd Font Mono";
          style = "Bold";
        };
        bold_italic = {
          family = "Hack Nerd Font Mono";
          style = "Bold Italic";
        };
        italic = {
          family = "Hack Nerd Font Mono";
          style = "Italic";
        };
        normal = {
          family = "Hack Nerd Font Mono";
          style = "Regular";
        };
      };
    };
  };


  nixpkgs.config.allowUnfree = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.
}
