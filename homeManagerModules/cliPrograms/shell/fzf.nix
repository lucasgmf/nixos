{
  lib,
  config,
  ...
}:
{
  options = {
    fzf.enable = lib.mkEnableOption "enable fzf (with zsh integration)";
  };

  config = lib.mkIf config.fzf.enable {
    programs.fzf = {
      enable = true;
      enableZshIntegration = if config.zsh.enable then true else false;
    };
  };
}
