DESTDIR ?= /usr/local
PASSWORDSTORE := $(or ${PASSWORD_STORE_DIR},$(HOME)/.password-store)
EXTENSIONS_DIR = ${PASSWORDSTORE}/.extensions
BASH_COMPLETIONS_DIR = ${PASSWORDSTORE}/.bash-completions
BASHCOMPDIR ?= /etc/bash_completion.d

install:
	@install -v -d "$(EXTENSIONS_DIR)/"
	@install -v -m 0755 paper.bash "$(EXTENSIONS_DIR)/paper.bash"
	@install -v -d "$(BASH_COMPLETIONS_DIR)/"
	@install -v -m 0755 pass-paper.bash.completion "$(BASH_COMPLETIONS_DIR)/pass-paper.bash.completion"
	@ln -f -s "$(BASH_COMPLETIONS_DIR)/pass-paper.bash.completion" "$(DESTDIR)$(BASHCOMPDIR)/pass-paper"
	@echo
	@echo "to finish installation, add"
	@echo
	@echo "   export PASSWORD_STORE_ENABLE_EXTENSIONS=true"
	@echo
	@echo "into your ~/.bashrc file"
	@echo

uninstall:
	@rm -vrf "$(EXTENSIONS_DIR)/paper.bash"
	@rm -vrf "$(BASH_COMPLETIONS_DIR)/pass-paper.bash.completion"
	@rm -vrf "$(DESTDIR)$(BASHCOMPDIR)/pass-paper"

lint:
	shellcheck -s bash paper.bash

.PHONY: install uninstall lint
