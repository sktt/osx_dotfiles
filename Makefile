DOTFILES := $(wildcard dot/*)

# symlink DOTFILES to home dir, substitute "dot/" with "."
symlink: $(DOTFILES)
	@for f in $(DOTFILES); do \
	 	ln -fs `pwd`/$$f ~/`echo $$f | sed s/dot\\\//./`; \
	done;
	@ls -lG `find ~ -maxdepth 1 -type l -print` 
default: symlink
