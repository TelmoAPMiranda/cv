.DEFAULT_GOAL := help

SHELL := /bin/bash
CI_CONTAINER_IMAGE_NAME ?= telmoapmiranda/cv

export PROJECT_ROOT=$(shell pwd)

# make help # Display available commands.
# Only comments starting with "# make " will be printed.
.PHONY: help
help:
	@egrep "^# make " [Mm]akefile | cut -c 3-

# make clean # Clean up the generated files.
.PHONY: clean
clean:
	@rm -rf generated
	@mkdir -p generated
	@chmod o+rw generated

# make generate-html # Generate the CV in HTML format.
.PHONY: generate-html
generate-html: clean
	npm install
	npm run export-html

# make prepare-github-pages # Prepare the gh-pages folder to be deployed. This will copy the generated CV to the gh-pages folder making sure the HTML file is renamed to "index.html". Note that this command expects the contents of the `generated` folder to already be generated.
.PHONY: prepare-github-pages
prepare-github-pages:
	mkdir -p github-pages
	cp -rn generated/. github-pages/

# make spell-check # Spell check the CV HTML file.
.PHONY: spell-check
spell-check: generate-html
	tidy -o generated/index.tidy.html -i -asxml -q --show-warnings false generated/index.html | exit 0
	@SPELL_CHECK_RESULT=$$(hunspell -d en_US -l -H -p spell-check-exclude.dic generated/index.tidy.html) && \
	rm generated/index.tidy.html && \
	(([[ $${SPELL_CHECK_RESULT} == "" ]] && echo "No spelling errors found.") || \
	(echo -e "Spelling errors found:\n\n$${SPELL_CHECK_RESULT}\n" && exit 1))