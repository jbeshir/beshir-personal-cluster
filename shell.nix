with (import (fetchTarball https://github.com/nixos/nixpkgs/archive/0747387223edf1aa5beaedf48983471315d95e16.tar.gz) {});

mkShell {
  buildInputs = [
    google-cloud-sdk
    ruby
    terraform
  ];
  shellHook = ''gcloud config set project beshir-personal'';
}