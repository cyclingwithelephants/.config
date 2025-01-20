#!/usr/bin/env bash

tmp_dir=/tmp/install_scripts/log-options-plus
pkg_path="${tmp_dir}/installer.zip"

if [[ -e /Applications/logioptionsplus.app/ ]]; then
	echo "already installed: logi-options-plus "
else
	echo "installing: logi-options-plus"
	mkdir -p "${tmp_dir}"
	cd "${tmp_dir}" || exit 1
	wget https://download01.logi.com/web/ftp/pub/techsupport/optionsplus/logioptionsplus_installer.zip -O "${pkg_path}"
	unzip "${pkg_path}" -d "${tmp_dir}"
	open "${tmp_dir}/logioptionsplus_installer.app"
fi
