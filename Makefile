REF          = reference
BIB          = $(REF)/bib.bib
CSL          = $(REF)/mla.csl

TEMPLATE     = templates
BUILD        = build

PANDOC       = /usr/bin/pandoc
PANDOC_FLAGS = --filter pandoc-citeproc \
	       --bibliography $(BIB) \
	       --csl $(CSL)
PREPARE      = ./prepare

src          = $(addprefix $(BUILD)/prep-,$(sort $(wildcard *.md)))
pdf          = $(subst prep-,,$(subst md,pdf,$(src)))
doc          = $(subst prep-,,$(subst md,docx,$(src)))
thesis       = $(BUILD)/thesis.pdf


all: standalone plain doc


standalone: PANDOC_FLAGS += --pdf-engine xelatex \
		            --toc \
                            --top-level-division chapter \
		            --template $(TEMPLATE)/thesis.latex \
		            --file-scope
standalone: clean prepare-standalone
	$(PANDOC) $(PANDOC_FLAGS) \
	    $(BUILD)/prep-pre.md $(src) $(BUILD)/prep-post.md \
	    -o $(thesis)


plain: PANDOC_FLAGS += --pdf-engine xelatex \
                       --template $(TEMPLATE)/plain.latex
plain: clean prepare-plain $(pdf)


prepare-standalone:
	$(PREPARE) fancy standalone


prepare-plain:
	$(PREPARE) plain all


doc: PANDOC_FLAGS += --reference-doc $(TEMPLATE)/mla.docx
doc: clean prepare-plain $(doc)


%.pdf: prep-%.md
	$(PANDOC) $(PANDOC_FLAGS) $< -o $@


%.docx: prep-%.md
	$(PANDOC) $(PANDOC_FLAGS) $< -o $@


.PHONY: clean
clean:
	@-rm -f $(BUILD)/*.pdf $(BUILD)/*.md
