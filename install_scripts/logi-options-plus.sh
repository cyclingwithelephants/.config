#!/usr/bin/env zsh

tmp_dir=/tmp/install_scripts/log-options-plus
pkg_path="${tmp_dir}/installer.zip"

if [[ -e /Applications/logioptionsplus.app/ ]]; then
	echo "already installed: logi-options-plus"
	exit 0
fi

echo "installing: logi-options-plus"
# WARN: the ZIP downloaded here has no checksum verification.
# If Logitech's CDN (download01.logi.com) were compromised, this would execute arbitrary code.
# To harden: download the installer manually, verify its hash, and replace this block.
mkdir -p "${tmp_dir}"
cd "${tmp_dir}" || exit 1
wget https://download01.logi.com/web/ftp/pub/techsupport/optionsplus/logioptionsplus_installer.zip -O "${pkg_path}"
unzip "${pkg_path}" -d "${tmp_dir}"
open "${tmp_dir}/logioptionsplus_installer.app"
