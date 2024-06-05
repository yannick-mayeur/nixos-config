{ lib, pkgs, bat-catppuccin, ... }:

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

  programs.zsh.initExtra = lib.mkForce ''
    alias ls='lsd'

    source ~/Repos/sweep-nix-wrapper/sweep/sweep

    OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

    eval "$(${lib.getExe pkgs.direnv} hook zsh)"
    eval "$(zoxide init zsh)"

    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
  '';

  home.file = {
    ".yabairc".source = ../common/dotfiles/yabairc;
    ".skhdrc".source = ../common/dotfiles/skhdrc;
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
