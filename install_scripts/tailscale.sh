#!/usr/bin/env zsh

tmp_dir=/tmp/install_scripts/tailscale
tailscale_pkg="${tmp_dir}/install.pkg"

if [[ "$(which tailscale)" == "" ]]; then
  echo "installing tailscale as it has not been found on the system"
  mkdir -p "${tmp_dir}"
  cd "${tmp_dir}" || exit 1
  wget https://pkgs.tailscale.com/stable/Tailscale-latest-macos.pkg -O "${tailscale_pkg}"
  open "${tailscale_pkg}"
else
  echo "tailscale GUI is already installed"
fi