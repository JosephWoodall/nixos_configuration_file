# nixos_configuration_file
holds the nixos configuration file to use across multiple desktops running nixos

## Workflow  
Install minimal NixOS.

git clone your repo.

Copy the machine's local /etc/nixos/hardware-configuration.nix into your repo folder.

Run sudo nixos-rebuild switch --flake .#new-machine-name.
