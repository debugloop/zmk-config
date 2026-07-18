{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    zmk-nix,
  }: let
    forAllSystems = nixpkgs.lib.genAttrs (nixpkgs.lib.attrNames zmk-nix.packages);
  in {
    packages = forAllSystems (system: rec {
      default = firmware;

      firmware = zmk-nix.legacyPackages.${system}.buildSplitKeyboard {
        name = "firmware";

        src = nixpkgs.lib.sourceFilesBySuffices self [
          ".board"
          ".cmake"
          ".conf"
          ".defconfig"
          ".dts"
          ".dtsi"
          ".json"
          ".keymap"
          ".overlay"
          ".shield"
          ".yml"
          "_defconfig"
        ];

        # board = "xiao_ble";
        board = "seeeduino_xiao_ble";
        shield = "totem_%PART%";
        snippets = ["zmk-usb-logging"];
        parts = [
          "dongle"
          "left"
          "right"
        ];
        # parts = ["left" "right"];
        # parts = ["dongle"];

        zephyrDepsHash = "sha256-0ni/3FJJizCqvp0X2tmwu29eWVqgd3hRXGOjtW6OiUE=";

        meta = {
          description = "ZMK firmware";
          license = nixpkgs.lib.licenses.mit;
          platforms = nixpkgs.lib.platforms.all;
        };
      };

      flash = zmk-nix.packages.${system}.flash.override {inherit firmware;};
      # reset = let
      #   firmware = zmk-nix.legacyPackages.${system}.buildKeyboard {
      #     name = "settings_reset";
      #     src = nixpkgs.lib.sourceFilesBySuffices self [
      #       ".board"
      #       ".cmake"
      #       ".conf"
      #       ".defconfig"
      #       ".dts"
      #       ".dtsi"
      #       ".json"
      #       ".keymap"
      #       ".overlay"
      #       ".shield"
      #       ".yml"
      #       "_defconfig"
      #     ];
      #     board = "seeeduino_xiao_ble";
      #     shield = "settings_reset";
      #     zephyrDepsHash = "sha256-IGyYY6MzYoHzVRlYioVy84GRH7ZN5uyQcarJIo5oHiQ=";
      #     meta = {
      #       description = "ZMK firmware";
      #       license = nixpkgs.lib.licenses.mit;
      #       platforms = nixpkgs.lib.platforms.all;
      #     };
      #   };
      # in
      #   zmk-nix.packages.${system}.flash.override {inherit firmware;};
      update = zmk-nix.packages.${system}.update;
    });

    devShells = forAllSystems (system: {
      default = zmk-nix.devShells.${system}.default;
    });
  };
}
