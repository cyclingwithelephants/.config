# Overriding the brew function only for install/uninstall
brew() {
  if [[ "$1" == "install" ]]; then
    shift
    brew_install_with_brewfile "$@"
  elif [[ "$1" == "uninstall" ]]; then
    shift
    brew_uninstall_with_brewfile "$@"
  else
    # Pass all other commands directly to the original brew command
    command brew "$@"
  fi
}