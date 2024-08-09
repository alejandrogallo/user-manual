-include config.mk
PYENV = env
SPHINX = $(PYENV)/bin/sphinx-build
BUILD_DIR = build
PATHSVR=/var/www/manuals.cc4s.org

PORT = 8888

EMACS_BIN ?= emacs
EMACS = $(EMACS_BIN) -Q --batch
INDEX = index.org
ORGFILES = $(shell find . -name '*.org' | grep -v '.emacs')
RSTFILES = $(patsubst %.org,%.rst,$(ORGFILES))
ID_LOCATION_FILE = id-locations
EMACS_SITE = $(EMACS) --load config/site.el


TANGLING_FILES = $(shell find . -name '*.org' | xargs grep -H tangle | awk -F: '{print $$1}')
TANGLING_FILES_DIR = .emacs/tangle
TANGLING_FILES_CACHE = $(patsubst %,$(TANGLING_FILES_DIR)/%,$(TANGLING_FILES))
$(TANGLING_FILES_DIR)/%: %
	mkdir -p $(@D)
	$(EMACS) $< -f org-babel-tangle && touch $@

.PHONY: rst all
all: build/index.html

$(SPHINX):
	virtualenv $(PYENV)
	$(PYENV)/bin/pip install sphinx sphinx-press-theme

build/index.html: $(SPHINX) rst
	$(SPHINX) -b html . $(BUILD_DIR)

rst: $(RSTFILES)
%.rst: %.org
	$(EMACS_SITE) $< -f org-rst-export-to-rst
	sed -i "s/\.rst/.html/g" $@
	sed -i "s/\.org/.html/g" $@

tangle: $(TANGLING_FILES_CACHE)

refresh:
	$(EMACS) --load config/site.el $(INDEX) -f package-refresh-contents

clean:
	rm -r $(BUILD_DIR) $(ID_LOCATION_FILE) .emacs/org-timestamps*

clean-emacs:
	rm -r .emacs

clean-all: clean clean-emacs

serve:
	python3 -m http.server $(PORT) --directory $(BUILD_DIR)

vim:
	mkdir -p ~/.vim/ftdetect
	mkdir -p ~/.vim/syntax
	wget https://raw.githubusercontent.com/alejandrogallo/org-syntax.vim/main/ftdetect/org.vim \
				-O ~/.vim/ftdetect/org.vim
	wget https://raw.githubusercontent.com/alejandrogallo/org-syntax.vim/main/syntax/org.vim \
				-O ~/.vim/syntax/org.vim

deploy: user-manual
	rsync --recursive --itemize-changes --delete $(BUILD_DIR) $(PATHSVR)

.PHONY: init serve tangle refresh clean clean-emacs clean-all force vim
