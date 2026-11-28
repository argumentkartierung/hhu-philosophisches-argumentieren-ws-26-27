.PHONY: all generate generate-force sync-assets website slides slides-pdf handouts assignments clean clean-all

SYNC_SRC ?= /home/sebastian/Nextcloud/Documents/mindmaps/code/quarto-course-template/assets
SYNC_DIRS := line-numbering markup
ASSETS_DIR := assets

# Generate stubs and config files from course.yaml
generate:
	quarto-coursegen generate

# Force regenerate all stubs (overwrites existing content)
generate-force:
	quarto-coursegen generate --force

# Sync shared feature assets from template repository.
# Override source path if needed: make SYNC_SRC=/path/to/template/assets website
sync-assets:
	@test -d "$(SYNC_SRC)" || (echo "Missing SYNC_SRC: $(SYNC_SRC)" && exit 1)
	@mkdir -p "$(ASSETS_DIR)"
	@for d in $(SYNC_DIRS); do \
		test -d "$(SYNC_SRC)/$$d" || (echo "Missing source dir: $(SYNC_SRC)/$$d" && exit 1); \
		echo "Syncing assets/$$d"; \
		mkdir -p "$(ASSETS_DIR)/$$d"; \
		rsync -a --delete "$(SYNC_SRC)/$$d/" "$(ASSETS_DIR)/$$d/"; \
	done

# Render the course website (HTML)
website: sync-assets
	quarto render

# Render slides (reveal.js + Beamer PDF via Quarto)
slides: sync-assets
	quarto render content/slides/

# Export slides to PDF using Decktape (requires decktape installed globally).
slides-pdf:
	for f in docs/content/slides/*.html; do \
		./node_modules/.bin/decktape reveal "$$f" "$${f%.html}.pdf"; \
	done

# Render handouts (PDF)
handouts: sync-assets
	quarto render content/handouts/

# Render assignments (HTML + PDF)
assignments: sync-assets
	quarto render content/assignments/

# Render everything
all: website slides-pdf

# Delete rendered output
clean:
	rm -rf docs/

# !! CAUTION — DEV USE ONLY !!
# Removes ALL generated files: rendered output AND generated stubs.
# Any content you have added to the stubs will be lost.
# Run 'make generate' afterwards to recreate stubs from course.yaml.
clean-all: clean
	rm -f index.qmd _quarto-nav.yml
	rm -f content/syllabus.qmd
	rm -f content/modules/*.qmd
	rm -f content/slides/*.qmd  content/slides/_quarto.yml
	rm -f content/handouts/*.qmd content/handouts/_quarto.yml
	rm -f content/notes/*.qmd
	rm -f content/assignments/*.qmd content/assignments/_quarto.yml
