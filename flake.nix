{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        system = "${system}";
        config = {
          allowUnfree = true;
        };
      };
      dependencies = with pkgs; [
        cudatoolkit
        cudaPackages.cuda_nvml_dev
        linuxPackages.nvidia_x11
      ];
      libPath = pkgs.lib.makeLibraryPath dependencies;
      binPath = pkgs.lib.makeBinPath dependencies;
      nvidia-pstated = pkgs.stdenv.mkDerivation {
        pname = "nvidia-pstated";
        version = "1.0.6";
        src = pkgs.fetchgit {
          url = "https://github.com/niki-on-github/nvidia-pstated.git";
          rev = "0e82e75327c9c5379aa54224ea42f0a15fe7704f";
          sha256 = "sha256-gzOK8ISoL+vqxJMfNgTaZCknXT7G6jsFjWIgKI30m+I=";
        };
        cmakeFlags = [ "-Wno-dev" "--compile-no-warning-as-error" "-DCFLAGS=-Wno-error" "-DCXXFLAGS=-Wno-error" ];
        buildInputs = dependencies;
        nativeBuildInputs = with pkgs; [
          cmake
          pkg-config
          makeWrapper
        ];
        postInstall = ''
          wrapProgram "$out/bin/nvidia-pstated" --prefix LD_LIBRARY_PATH : "${libPath}" --prefix PATH : "${binPath}"
        '';
      };
    in
    {
      packages.${system}.nvidia-pstated = nvidia-pstated;
      defaultPackage.${system} = self.packages.${system}.nvidia-pstated;
      formatter.${system} = pkgs.nixpkgs-fmt;
      devShells.${system}.default = pkgs.mkShell {
        LD_LIBRARY_PATH = libPath;
        buildInputs = dependencies;
        nativeBuildInputs = with pkgs; [
          cmake
          pkg-config
        ];
      };
    };
}
