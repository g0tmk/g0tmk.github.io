
.PHONY: server
.PHONY: new
.PHONY: check-%
.PHONY: install-deps

all: server

server: check-hugo
	@sleep 1 && xdg-open http://localhost:1313/ &
	hugo server -D

new: check-hugo
	@echo "Enter the title of the new post: "
	@read title \
		&& hugo new content --kind post posts/$$title.md


##############################################################################
# Prereq installers

check-hugo:
	@# Check if hugo exists in PATH, if not, install via snap.
	@set -e ; \
	MODULE=hugo ; \
	command -v "$$MODULE" > /dev/null \
	    || (echo "Missing $$MODULE. Want to intall now? " \
	        && echo -n "(command: sudo snap install $$MODULE) [y/N]" \
	        && read ans && [ $${ans:-N} = y ] \
	        && sudo snap install "$$MODULE");

check-pip-%:
	@# Check if a command exists in PATH, if not, install via pip
	@# A shell variable is used to store the dependency name, so all
	@# commands that use that variable must be combined into one subshell.
	@# The set -e causes early exit on failure.
	@set -e ; \
	MODULE=$$(echo "$@" | sed "s/check-pip-//g") ; \
	command -v "$$MODULE" > /dev/null \
	    || (echo "Missing $$MODULE. Want to intall now? " \
	        && echo -n "(command: pip install $$MODULE) [y/N]" \
	        && read ans && [ $${ans:-N} = y ] \
	        && pip install "$$MODULE");

check-apt-%:
	@# Check if a command exists in PATH, if not, install via apt
	@# A shell variable is used to store the dependency name, so all
	@# commands that use that variable must be combined into one subshell.
	@# The set -e causes early exit on failure.
	@set -e ; \
	MODULE=$$(echo "$@" | sed "s/check-apt-//g") ; \
	command -v "$$MODULE" > /dev/null \
	    || (echo "Missing $$MODULE. Want to intall now? " \
	        && echo -n "(command: sudo apt update && sudo apt install $$MODULE) [y/N]" \
	        && read ans && [ $${ans:-N} = y ] \
	        && sudo apt update && sudo apt install "$$MODULE");

install-deps: check-hugo
	@echo "All dependencies are installed."