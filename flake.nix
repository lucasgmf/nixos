{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix";

    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = {
    self,
    nixpkgs,
    secrets,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;

    user = {
      name = "lucasgmf";
      description = "Lucas Freitas";
      email = "lucasgalvaomfreitas@gmail.com";
      uid = 1000;
    };

    homeConfig = homeConfigPath: [
      ./nixosModules
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "backup";
          verbose = true;

          extraSpecialArgs = {
            inherit inputs user;
          };

          users.${user.name} = import homeConfigPath;
          sharedModules = [
            inputs.stylix.homeModules.stylix
          ];
        };
      }
    ];
  in {
    nixosConfigurations = {
      nix-laptop = lib.nixosSystem {
        specialArgs = {
          inherit inputs user;
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
