{
  lib,
  pkgs,
  ...
}:
{
  programs.fish.enable = lib.mkDefault true;
  programs.zsh.enable = lib.mkDefault true;

  environment.systemPackages = with pkgs; [
    bat
    btop
    fd
    git
    neovim
    ripgrep
    vim
  ];
}
