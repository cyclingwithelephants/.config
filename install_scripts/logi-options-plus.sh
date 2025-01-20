#!/usr/bin/env bash

if [[ -e /Applications/logioptionsplus.app/ ]]; then
  tmp_dir=/tmp/install_scripts/log-options-plus
  pkg_path="${tmp_dir}/installer.zip"
  echo "installing logi-options-plus as it has not been found on the system"
  mkdir -p "${tmp_dir}"
  cd "${tmp_dir}" || exit 1
  wget https://download01.logi.com/web/ftp/pub/techsupport/optionsplus/logioptionsplus_installer.zip -O "${pkg_path}"
  unzip "${pkg_path}" -d "${tmp_dir}"
  open "${tmp_dir}/logioptionsplus_installer.app"
else
  echo "logi-options-plus already installed"
fi
