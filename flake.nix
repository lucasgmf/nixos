{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";

    stylix.url = "github:danth/stylix";

    hyprland = {
      type = "git";
      url = "https://github.com/hyprwm/Hyprland";
      submodules = true;
    };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Wayland widgets lib
    ags.url = "github:Aylur/ags";
    swww.url = "github:LGFae/swww";

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    pkgs-stable = import nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };

    user = {
      name = "lucasgmf";
      description = "Lucas Freitas";
      email = "lucasgalvaomfreitas@gmail.com";
      uid = 1000;
    };

    homeConfig = homeConfigPath: [
      ./nixosModules
      inputs.stylix.nixosModules.stylix

      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "backup";

          extraSpecialArgs = {
            inherit inputs user pkgs-stable;
          };

          users.${user.name} = import homeConfigPath;
        };
      }
    ];
  in {
    nixosConfigurations = {
      nix-laptop = lib.nixosSystem {
        specialArgs = {
          inherit inputs user pkgs-stable;
        };

        modules =
          [
            ./hosts/nix-laptop
          ]
          ++ homeConfig ./homeManagerModules/laptop.nix;
      };
    };
  };
}
