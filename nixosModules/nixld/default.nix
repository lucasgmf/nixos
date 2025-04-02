{ config, pkgs, ... }: 
{
  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld; # or pkgs.nix-ld if you prefer the original implementation
  };
}

