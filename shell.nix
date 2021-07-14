let
  pkgs = import (builtins.fetchGit {             
     name = "beshir-personal-cluster-main";
     url = "https://github.com/NixOS/nixpkgs/";
     ref = "refs/heads/nixos-unstable";
     rev = "860b56be91fb874d48e23a950815969a7b832fbc";
  }) {};
  mkShell = pkgs.mkShell;

  python = pkgs.python37Full;  # 3.7.10
  go = pkgs.go;  # 1.16.5
in (
  mkShell {
    buildInputs = [
        python
        go
    ];

    # Get Pulumi and gcloud.
    shellHooks = ''if [[ -d $PWD/.pulumi ]]; then export PATH=$PATH:$PWD/.pulumi; else curl -O https://get.pulumi.com/releases/sdk/pulumi-v3.6.1-linux-x64.tar.gz;tar -xf pulumi-v3.6.1-linux-x64.tar.gz;rm pulumi-v3.6.1-linux-x64.tar.gz;mv pulumi .pulumi;export PATH=$PATH:$PWD/.pulumi;fi;if [[ -d $PWD/.google-cloud-sdk ]]; then export PATH=$PATH:$PWD/.google-cloud-sdk/bin; else curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-346.0.0-linux-x86_64.tar.gz;tar -xf google-cloud-sdk-346.0.0-linux-x86_64.tar.gz;rm google-cloud-sdk-346.0.0-linux-x86_64.tar.gz;mv google-cloud-sdk .google-cloud-sdk;export PATH=$PATH:$PWD/.google-cloud-sdk/bin;gcloud components install kubectl;fi'';
  }
)