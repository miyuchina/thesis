REF          = ./reference
BIB          = $(REF)/bib.bib
CSL          = $(REF)/mla.csl

TEMPLATES    = ./templates
BUILD        = ./build
BIN          = ./bin

PANDOC       = /usr/bin/pandoc
PANDOC_FLAGS = --filter pandoc-citeproc \
	       --bibliography $(BIB) \
	       --csl $(CSL)
PREPARE      = $(BIN)/prepare
CHAPTERS     = $(BIN)/chapters

src          = $(sort $(wildcard *.md))
section-src  = $(addprefix $(BUILD)/,$(src))
thesis-src   = $(BUILD)/pre.md $(section-src) $(BUILD)/post.md

print-pdf    = $(BUILD)/print.pdf
thesis-pdf   = $(BUILD)/thesis.pdf
chapter-pdf  = $(addprefix $(BUILD)/,$(addsuffix .pdf,$(shell $(CHAPTERS))))
section-pdf  = $(subst md,pdf,$(section-src))


all: print thesis chapter section


print: PANDOC_FLAGS += --pdf-engine xelatex \
		       --toc \
                       --top-level-division chapter \
		       --template $(TEMPLATES)/print.latex \
		       --file-scope
print: $(thesis-src)
	$(PANDOC) $(PANDOC_FLAGS) $^ -o $(print-pdf)


thesis: PANDOC_FLAGS += --pdf-engine xelatex \
                        --top-level-division chapter \
		        --template $(TEMPLATES)/thesis.latex \
		        --file-scope
thesis: $(thesis-src)
	$(PANDOC) $(PANDOC_FLAGS) $^ -o $(thesis-pdf)


chapter: PANDOC_FLAGS += --pdf-engine xelatex \
                         --template $(TEMPLATES)/chapter.latex \
		         --file-scope
chapter: $(chapter-pdf)


section: PANDOC_FLAGS += --pdf-engine xelatex \
                         --template $(TEMPLATES)/section.latex
section: $(section-pdf)


$(BUILD)/%.pdf: $(BUILD)/%.md
	$(PANDOC) $(PANDOC_FLAGS) $< -o $@


.SECONDEXPANSION:
$(BUILD)/%.pdf: $$(shell $(CHAPTERS) %)
	$(PANDOC) $(PANDOC_FLAGS) $^ -o $@


$(BUILD)/%.md: %.md
	$(PREPARE) $<


$(BUILD)/%.md:
	$(PREPARE)


.PHONY: clean
clean:
	rm -f $(BUILD)/*.pdf $(BUILD)/*.md
