SHELL			=		/bin/sh

RM				=		rm
ECHO			=		echo
COPY			=		cp

R				=		Rscript

RMD_FILENAME	=		flights_of_new_york
HTML			=		$(RMD_FILENAME).html
PDF				=		$(RMD_FILENAME).pdf
MD				=		$(RMD_FILENAME).md

HTML_OUTPUT		=		html_document
PDF_OUTPUT		=		pdf_document
MD_OUTPUT		=		github_document

HTML_EXT		=		%.html : %.Rmd
PDF_EXT			=		%.pdf : %.Rmd
MD_EXT			=		%.md : %.Rmd

ALL_FILES		=		$(PDF)													\
						$(HTML)

CLEAN_FILES		=		*_files/												\
						*_cache/												\
						$(PDF:.pdf=.synctex.gz)									\
						$(PDF:.pdf=.tex)

define cleanup
	-$(RM) -rf $(CLEAN_FILES)
	-$(RM) -f $(ALL_FILES)
endef

define rmarkdown_render
	$(R) -e "rmarkdown::render(input='$<', output_file='$@',					\
			 output_format='$(1)')"
endef

.SILENT :
.PHONY : all clean

all : $(ALL_FILES)

clean :
	$(call cleanup)

$(HTML) : $(HTML_EXT)
	$(call rmarkdown_render,$(HTML_OUTPUT))

$(PDF) : $(PDF_EXT)
	$(call rmarkdown_render,$(PDF_OUTPUT))

$(MD) : $(MD_EXT)
	$(call rmarkdown_render,$(MD_OUTPUT))
