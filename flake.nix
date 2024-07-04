{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs: {
    nixosConfigurations = {

    	default = nixpkgs.lib.nixosSystem {

			specialArgs = {inherit inputs;};
			modules = [
				./hosts/default

				home-manager.nixosModules.home-manager{
					home-manager.useGlobalPkgs = true;
					home-manager.useUserPackages = true;

					home-manager.extraSpecialArgs = inputs;
					home.manager.users.dvalinn = import ./home;

				}
			];

		};
    	
	};
}
