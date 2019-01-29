MIN := .min

PAGES := site/home.html site/packages.html site/docs.html site/reports.html
INCLUDES := src/include/head.html src/include/header.html                      \
            src/include/footer.html
SCRIPTS := site/js/utils$(MIN).js site/js/packages$(MIN).js                    \
           site/js/docs$(MIN).js site/js/reports$(MIN).js

PYTHON := python
COFFEE := coffee
MINIFY := google-closure-compiler


all: $(PAGES) $(SCRIPTS)

site/%.html: src/pages/%.html $(INCLUDES)
	@echo ">_HTML $<"
	@$(PYTHON) generate-html.py $<

site/js/%.js: src/coffee/%.coffee
	@mkdir -p site/js
	@echo "COFFEE $<"
	@$(COFFEE) -o site/js -c $<

site/js/%.min.js: site/js/%.js
	@echo "MINIFY $<"
	@$(MINIFY) --js $< --js_output_file $@
	@rm -f $<

clean:
	@rm -rf $(PAGES) site/js
