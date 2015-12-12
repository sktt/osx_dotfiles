# symlink DOTFILES to home dir, substitute "dot/" with "."
symlinks: DOTFILES := $(wildcard dot/*)
symlinks:
	@for f in $(DOTFILES); do \
	 	ln -fs `pwd`/$$f ~/`echo $$f | sed s/dot\\\//./`; \
	done;
	@ls -lG `find ~ -maxdepth 1 -type l -print` 

fonts:
	curl -L https://github.com/powerline/fonts/raw/master/SourceCodePro/Sauce%20Code%20Powerline%20Regular.otf -o ~/Library/Fonts/Sauce\ Code\ Powerline\ Regular.otf

.PHONY: hosts
hosts:
	sudo -s "cp ./hosts /etc/hosts"

.PHONY: packages
packages: CASKS := $(shell cat ./packages/cask.list)
packages: BREWS := $(shell cat ./packages/brew.list)
packages:
	ruby -e "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	brew tap caskroom/cask
	brew tap neovim/neovim
	brew install $(BREWS)
	brew cask install $(CASKS)

lists:
	npm ls -g --depth=0 | awk '/@/ {print $$2}' | awk -F@ '{print $$1}' > ./packages/npm.list
	pip list | awk -F\  '{print $$1}' > ./packages/pip.list
	gem list | awk -F\  '{print $$1}' > ./packages/gem.list
	cp /etc/hosts ./hosts
	brew list > ./packages/brew.list
	brew cask list > ./packages/cask.list

nvim: python 
	git clone git@github.com:VundleVim/Vundle.vim.git ~/.nvim/bundle/Vundle.vim
	nvim -u ~/.nvimrc -c PluginInstall

python: packages
python: PKG_LIST := $(shell cat ./packages/pip.list)
python:
	@which pip > /dev/null
	pip install $(PKG_LIST)

node: packages
node: PKG_LIST := $(shell cat ./packages/npm.list)
node: NVM := /usr/local/opt/nvm/nvm.sh
node:
	@which $(NVM) > /dev/null
	$(NVM) install stable
	$(NVM) alias default stable
	npm install -g $(PKG_LIST)

ruby: packages
ruby: LATEST_STABLE := $(shell rbenv install -l | grep -v - | tail -1)
ruby: PKG_LIST := $(shell cat ./packages/gem.list)
ruby:
	rbenv install $(LATEST_STABLE)
	rbenv global $(LATEST_STABLE)
	rbenv rehash
	gem install $(PKG_LIST)

shell: packages
shell:
	@which git > /dev/null
	@which zsh > /dev/null
	git clone --depth=1 git@github.com:robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
	chsh -s `which zsh`

all: symlinks fonts hosts packages shell ruby node python nvim
