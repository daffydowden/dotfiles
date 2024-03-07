{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # controls system preferences and settings
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # everything
    # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-23.11-darwin";
    # nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # manages config links into home directory
    #home-manager.url = "github:nix-community/home-manager/master";
    #home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
          pkgs.neovim
          pkgs.eza
          pkgs.coreutils
        ];

      environment.darwinConfig = "$HOME/projects/dotfiles";

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      # programs.zsh.enable = true;  # default shell on catalina
      programs.zsh.enable = true;
      programs.fish.enable = true;
      environment.shells = [ pkgs.bash pkgs.zsh pkgs.fish ];
      environment.loginShell = pkgs.fish;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "x86_64-darwin";

      system.keyboard.enableKeyMapping = true;
      system.keyboard.remapCapsLockToControl = true;

      #fonts.fontsDir.enable = false; # DANGER - setting to true will delete other fonts
      #fonts.fonts = [ pkgs.powerline-fonts (pkgs.nerd-fonts.override { fonts = [ "Meslo" "FiraCode"] }; )];
      # nerdfonts.override { withFont = "FiraCode"; })
      #fonts.fonts = [ (pkgs.nerd-fonts.override { fonts = [ "Meslo" ] }) ];

      system.defaults.finder.AppleShowAllFiles = true;
      system.defaults.finder.AppleShowAllExtensions = true;
      system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
      system.defaults.NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically = true;
      system.defaults.NSGlobalDomain.InitialKeyRepeat = 14;
      system.defaults.NSGlobalDomain.KeyRepeat = 1;
      system.defaults.dock.autohide = true;

      system.defaults.menuExtraClock.Show24Hour = true;
      system.defaults.menuExtraClock.ShowDate = 0;
      system.defaults.menuExtraClock.ShowDayOfMonth = true;
      system.defaults.menuExtraClock.ShowDayOfWeek = true;
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Richards-MacBook-Air-3
    darwinConfigurations."Richards-MacBook-Air-3" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."Richards-MacBook-Air-3".pkgs;
  };
}
