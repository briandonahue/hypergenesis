section() {
  echo ""
  echo "##################################################"
  echo "                   $1"
  echo "##################################################"
  echo ""
}

log() {
  echo ""
  echo " ==> $1"
  echo ""
}

install_application_via_app_store() {
	if ! mas list | grep $1 &> /dev/null; then
		log "Installing $2"
		mas install $1 >/dev/null
	else
		log "$2 already installed. Skipped."
	fi
}

install_npm_packages() {
  [[ -z $(npm ls -gp $1) ]] && (
    log "npm install -g $1" && npm install -g --silent $1
  ) || log "$1 already installed"
}

install_brews() {
  install_m1_brew $1
  if ! [[ $($?) -eq 0 ]]; then 
    install_intel_brew $1
  fi
}

install_m1_brew() {
  if test $(brew list | grep $1); then
  	log "$1 already installed for ARM arch. Skipped."
    return 0
  else
    if [[ -n $(brew search --formula $1) ]]; then
      log "Installing $1 for ARM arch"
      brew install --formula $1 >/dev/null
      return 0
    fi
  fi
  return 1
}

install_intel_brew() {
  if test $(ibrew list | grep $1); then
  	log "$1 already installed for Intel arch. Skipped."
    return 0
  else
    log "Installing $1 for Intel arch"
    ibrew install --formula $1 >/dev/null
    return 0
  fi
  return 1
}
