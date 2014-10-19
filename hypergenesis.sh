#!/bin/bash

set -e

#
#             Configuration
# - - - - - - - - - - - - - - - - - - - - - -

brewInstalls=(
  git
  grc
  caskroom/cask/brew-cask
  thoughtbot/formulae/rcm
  vim
  hub
  gnu-tar
  tmux
  htop-osx
  ctags
  nginx
  gnu-sed
  mobile-shell
  nmap
  tree
  wget
  watch
  macvim
  rabbitmq
  the_silver_searcher
 )

# Apps to install
brewCaskInstalls=(
  alfred
  google-chrome
  google-hangouts
  google-drive
  transmission
  hazel
  istat-menus
  bartender
  atom
  fluid
  virtualbox
  vagrant
  onepassword
  omnifocus
  omnifocus-clip-o-tron
  dropbox
  evernote
  mailbox
  firefox
  iterm2
  viscosity
  arq
  transmit
  vlc
  textexpander
  qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv betterzipql webp-quicklook
  suspicious-package
 )

dotfiles_repo='git@github.com:mattmcmanus/dotfiles.git'
dotfiles_location="$HOME/.dotfiles"

# Node apps to npm install -g
nodeGlobalModules=(jsontool node-dev bunyan grunt-cli autoprefixer bower clean-css coffee-script)


#
#     Functions make things easier!
# - - - - - - - - - - - - - - - - - - - - - -
log() {
  echo ""
  echo " ==> $1"
  echo ""
}

#
#         Commence Installations
# - - - - - - - - - - - - - - - - - - - - - -

#if [[ ! $(pkgutil --pkg-info=com.apple.pkg.DeveloperToolsCLI) ]]; then
#  xcode-select --install
#
#  echo "ERROR: XCode command line tools are NOT installed. The install should popup now. Retart your terminal when complete. Exiting..."
#  echo ""
#  echo "If you need help installing, go to http://stackoverflow.com/a/9329325/109589"
#  exit 1
#fi

echo ''
echo '       * * * * * * * * * * * * * * INITIATING * * * * * * * * * * * * * * '
echo''
echo '	    __  __                                                  '
echo '	   / / / /_  ______  ___  _______                           '
echo '	  / /_/ / / / / __ \/ _ \/ _____/                     _     '
echo '	 / __  / /_/ / /_/ /  __/ / ____/__  ____  ___  _____(_)____'
echo '	/_/ /_/\__, / .___/\___/_/ / __/ _ \/ __ \/ _ \/ ___/ / ___/'
echo '	      /____/_/          / /_/ /  __/ / / /  __(__  ) (__  ) '
echo '	                        \____/\___/_/ /_/\___/____/_/____/  '
echo ''
echo '       * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * '
echo ''
echo 'This script will do the following:'
echo ''
echo '1. Install homebrew'
echo "2. brew install ${brewInstalls[*]}"
echo "3. brew cask install ${brewCaskInstalls[*]}"
echo "4. Setup your dotfiles ($dotfiles_repo) into $dotfiles_location"
echo "5. Install NVM and node.js $nodeVersion"
echo "6. npm install -g ${nodeGlobalModules[*]}"
echo "7. Install RVM and ruby $rubyVersion"
echo ''

read -p "Are you ok with this? " -n 1

if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi
echo ""

# Install homebrew
[[ ! $(which brew) ]] &&
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &&
  brew doctor


brew update

# Brew installs
for app in "${brewInstalls[@]}"; do
  [[ $(brew info $app | grep "Not installed") ]] && log "brew install $app" && brew install $app
done


# Cask installs
for app in "${brewCaskInstalls[@]}"; do
  [[ $(brew cask info $app | grep "Not installed") ]] &&
    log "brew cask install $app" &&
    brew cask install $app
done

# Reload Quicklook
#qlmanage -r


# Setup dotfiles
[ ! -d $dotfiles_location ] && (
  log "Setting up your dotfiles repo"
  git clone $dotfiles_repo $dotfiles_location
)

rcup

# Install node
[ ! -d $HOME/.nvm ] && (
  log "Installing NVM"
  curl https://raw.github.com/creationix/nvm/master/install.sh | sh
  source ~/.bash_profile
  nvm install stable
  nvm alias default stable
)

# source ~/.bash_profile

for module in "${nodeGlobalModules[@]}"; do
  [[ -z $(npm ls -gp $module) ]] && (
    log "npm install -g $module" &&
    npm install -g $module
  )
done

[ ! -d $HOME/.rvm ] && (
  log "Installing RVM"
  \curl -sSL https://get.rvm.io | bash -s stable --ruby
)

[[ ! $(which bundler) ]] && (
  gem update --system
  gem install bundler --no-document --pre
  number_of_cores=$(sysctl -n hw.ncpu)
  bundle config --global jobs $((number_of_cores - 1))
 )

[[ ! $(which foreman) ]] &&
  curl -sLo /tmp/foreman.pkg http://assets.foreman.io/foreman/foreman.pkg && \
  sudo installer -pkg /tmp/foreman.pkg -tgt /


echo '           ________  _            '
echo '          |_   __  |(_)           '
echo '            | |_ \_|__   _ .--.   '
echo '            |  _|  [  | [ `.-. |  '
echo '           _| |_    | |  | | | |  '
echo '          |_____|  [___][___||__] '
echo '                                  '
