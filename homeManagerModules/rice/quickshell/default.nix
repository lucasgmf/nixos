{
  pkgs,
  inputs,
  ...
}: let
  ii = pkgs.symlinkJoin {
    name = "quickshell-ii";
    paths = [
      ./ii
      (pkgs.runCommand "shapes" {} ''
        mkdir -p $out/modules/common/widgets
        ln -s ${inputs.rounded-polygon-qmljs} $out/modules/common/widgets/shapes
      '')
    ];
  };
in {
  home.packages = [
    inputs.quickshell.packages.${pkgs.system}.default
  ];

  xdg.configFile."quickshell/ii".source = ii;
}
