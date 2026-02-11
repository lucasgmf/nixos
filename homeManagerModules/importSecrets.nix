# homeManagerModules/importSecrets.nix
{ inputs, ... }:

let
  secretsPath = inputs.secrets;

  importDir =
    dir:
    if builtins.pathExists dir then
      let
        files = builtins.readDir dir;
        nixFiles = builtins.filter (f: builtins.match "\\.nix$" f != null) (builtins.attrNames files);
        attrs = builtins.listToAttrs (
          map (f: {
            name = builtins.removeSuffix ".nix" f;
            value = import "${dir}/${f}";
          }) nixFiles
        );
      in
      attrs
    else
      { };

in
importDir secretsPath
