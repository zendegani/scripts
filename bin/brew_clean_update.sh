#!/usr/bin/env bash

brew update
brew upgrade
brew cleanup -s
brew cask cleanup
#now diagnotic
brew doctor
brew missing
apm upgrade -c false
#/opt/bin/updateCCTF.sh && terminal-notifier -message “git pull done :-)” -title “CCTF up to date”
#echo “you can hit mas upgrade to upgrade theses apps from the app store:”
#mas outdated
#echo “install with: mas upgrade”
#npm update -g
#echo “did you think to launch gem update “
#echo “and pip ? pip freeze — local | grep -v ‘^\-e’ | cut -d = -f 1 | xargs pip install -U “
