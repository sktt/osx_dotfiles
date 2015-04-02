DOTFILES := $(wildcard dot/*)

# symlink DOTFILES to home dir, substitute "dot/" with "."
symlink: $(DOTFILES)
	@for f in $(DOTFILES); do ln -f -s `pwd`/$$f ~/$$(echo $$f | sed s/dot\\//./); done

default: symlink
