{
  pkgs,
  inputs,
  ...
}: let
  # Python env with deps needed by kmeans_palette.py
  pythonEnv = pkgs.python3.withPackages (ps: [
    ps.pillow
    ps.numpy
    ps.scikit-learn
  ]);

  # Standalone executable wrapping the script with the right python
  kmeansScript = pkgs.writeShellApplication {
    name = "kmeans_palette";
    runtimeInputs = [pythonEnv];
    text = ''
      exec python3 ${./ii/schemePicker/kmeans_palette.py} "$@"
    '';
  };

  ii = pkgs.symlinkJoin {
    name = "quickshell-ii";
    paths = [
      ./ii
      (pkgs.runCommand "shapes" {} ''
        mkdir -p $out/modules/common/widgets
        ln -s ${inputs.rounded-polygon-qmljs} $out/modules/common/widgets/shapes
      '')
      # Symlink the wrapper binary so Quickshell.shellPath("schemePicker/kmeans_palette.py") works
      (pkgs.runCommand "kmeans-in-tree" {} ''
        mkdir -p $out/schemePicker
        ln -s ${kmeansScript}/bin/kmeans_palette $out/schemePicker/kmeans_palette.py
      '')
    ];
  };
in {
  home.packages = [
    inputs.quickshell.packages.${pkgs.system}.default
    kmeansScript
  ];
  xdg.configFile."quickshell/ii".source = ii;
}
