BUILD        := build
THESIS       := thesis
BIBLIOGRAPHY := bib.bib

TEMPLATE     := template.tex
CHAPTERS     := $(sort $(wildcard *.md))
INCLUDES     := $(wildcard *.tex)

LATEX        := $(shell which xelatex)
LATEX_FLAGS  := $(if $(DEBUG),,-interaction=batchmode)

BIBER        := $(shell which biber)
BIBER_FLAGS  := $(if $(DEBUG),,--quiet)

PANDOC       := $(shell which pandoc)
PANDOC_FLAGS := --pdf-engine xelatex \
		--biblatex \
		--template $(TEMPLATE) \
		--top-level-division chapter \
		--file-scope


$(THESIS).pdf: $(BUILD)/$(THESIS).pdf
	cp $< $@

$(BUILD)/$(THESIS).pdf: $(BUILD)/$(THESIS).bbl
	cd $(BUILD) && $(LATEX) $(LATEX_FLAGS) $(THESIS).tex

$(BUILD)/$(THESIS).bbl: $(BUILD)/$(THESIS).bcf $(BUILD)/$(BIBLIOGRAPHY)
	cd $(BUILD) && $(BIBER) $(BIBER_FLAGS) $(THESIS)

$(BUILD)/$(THESIS).bcf: $(addprefix $(BUILD)/,$(INCLUDES)) $(BUILD)/$(THESIS).tex
	cd $(BUILD) && $(LATEX) $(LATEX_FLAGS) $(THESIS).tex

$(BUILD)/$(THESIS).tex: $(CHAPTERS) $(TEMPLATE)
	$(PANDOC) $(PANDOC_FLAGS) $(CHAPTERS) -o $@

$(BUILD)/%: %
	cp $< $@


.PHONY: clean columns

clean:
	rm --force --verbose $(BUILD)/*
