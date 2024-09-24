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

# make prepare-github-pages # Prepare the github-pages folder to be deployed. This will copy the generated CV to the github-pages folder. Note that this command expects the contents of the `generated` folder to already be generated.
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

# make spell-check-readme # Spell check the README.md file.
.PHONY: spell-check-readme
spell-check-readme:
	hunspell -d en_US -l -H -p spell-check-exclude.dic README.md

# make format-spell-check-exclude-file # Format the spell-check-exclude.dic file used to exclude spell checker errors. This will sort and remove duplicate lines from the file.
.PHONY: format-spell-check-exclude-file
format-spell-check-exclude-file:
	SPELL_CHECK_FORMAT_RESULT=$$(cat spell-check-exclude.dic | egrep . | sort | uniq) && echo "$${SPELL_CHECK_FORMAT_RESULT}" > spell-check-exclude.dic