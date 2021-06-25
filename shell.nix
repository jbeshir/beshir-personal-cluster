with (import (fetchTarball https://github.com/nixos/nixpkgs/archive/0747387223edf1aa5beaedf48983471315d95e16.tar.gz) {});

mkShell {
  buildInputs = [
    openssl
    python3
    ruby
    terraform
  ];
  shellHooks = ''if [[ -d $PWD/google-cloud-sdk ]]; then export PATH=$PATH:$PWD/google-cloud-sdk/bin; else curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-346.0.0-linux-x86_64.tar.gz;tar -xf google-cloud-sdk-346.0.0-linux-x86_64.tar.gz;rm google-cloud-sdk-346.0.0-linux-x86_64.tar.gz;export PATH=$PATH:$PWD/google-cloud-sdk/bin;gcloud components install kubectl;fi'';
}