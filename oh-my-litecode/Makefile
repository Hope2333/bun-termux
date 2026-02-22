# Oh-My-Litecode - Top-level Makefile
#
# Usage:
#   make build          - Build all sub-projects
#   make build-project  - Build specific project (PROJECT=opencode|bun)
#   make clean          - Clean build artifacts
#   make release        - Create release packages
#
# Variables:
#   VER       - Target version (e.g., 1.1.65)
#   PKGMGR    - Package manager: pacman (default) or dpkg
#   DEBUG     - Build debug package: true or false (default)
#   PROJECT   - Project to build: opencode, bun, or all (default)

SHELL := /bin/bash
.DEFAULT_GOAL := help

# Version info
OML_VERSION := 0.1.0-alpha

# Build parameters (can be overridden)
VER ?= current
PKGMGR ?= pacman
DEBUG ?= false
PROJECT ?= all

# Directories
ROOT_DIR := $(shell pwd)
SOLVE_ANDROID := $(ROOT_DIR)/solve-android
DIST_DIR := $(ROOT_DIR)/dist
TMP_DIR := $(ROOT_DIR)/.tmp

# Sub-projects
SUBPROJECTS := opencode bun

# Package naming convention:
# {project}{,-debug}-{ver}-{relfix}.{pkgmgr}
# Examples:
#   opencode-1.1.65-1.pacman.tar.xz
#   opencode-debug-1.1.65-1.pacman.tar.xz
#   bun-1.2.20-1.dpkg.deb

.PHONY: help build clean release build-project test

help:
	@echo "Oh-My-Litecode Build System"
	@echo ""
	@echo "Usage: make [target] [VARIABLE=value]"
	@echo ""
	@echo "Targets:"
	@echo "  build          Build all sub-projects"
	@echo "  build-project  Build specific project (PROJECT=opencode|bun)"
	@echo "  clean          Clean build artifacts"
	@echo "  release        Create release packages"
	@echo "  test           Run tests"
	@echo ""
	@echo "Variables:"
	@echo "  VER=$(VER)           Target version"
	@echo "  PKGMGR=$(PKGMGR)     Package manager (pacman|dpkg)"
	@echo "  DEBUG=$(DEBUG)       Build debug package"
	@echo "  PROJECT=$(PROJECT)   Project to build"

# Build all sub-projects
build: $(SUBPROJECTS)
	@echo "Build complete for all projects"

# Build specific sub-project
opencode:
	@$(MAKE) -C $(SOLVE_ANDROID)/opencode build \
		VER=$(VER) PKGMGR=$(PKGMGR) DEBUG=$(DEBUG)

bun:
	@$(MAKE) -C $(SOLVE_ANDROID)/bun build \
		VER=$(VER) PKGMGR=$(PKGMGR) DEBUG=$(DEBUG)

# Build single project
build-project:
ifndef PROJECT
	$(error PROJECT must be specified (opencode or bun))
endif
	@$(MAKE) -C $(SOLVE_ANDROID)/$(PROJECT) build \
		VER=$(VER) PKGMGR=$(PKGMGR) DEBUG=$(DEBUG)

# Create release packages
release: build
	@mkdir -p $(DIST_DIR)
	@for proj in $(SUBPROJECTS); do \
		echo "Packaging $$proj..."; \
		$(MAKE) -C $(SOLVE_ANDROID)/$$proj package \
			VER=$(VER) PKGMGR=$(PKGMGR) DEBUG=$(DEBUG); \
	done
	@echo "Release packages created in $(DIST_DIR)"

# Clean build artifacts
clean:
	@rm -rf $(TMP_DIR)
	@for proj in $(SUBPROJECTS); do \
		$(MAKE) -C $(SOLVE_ANDROID)/$$proj clean; \
	done
	@echo "Clean complete"

# Run tests
test:
	@echo "Running tests..."
	@for proj in $(SUBPROJECTS); do \
		if [ -f "$(SOLVE_ANDROID)/$$proj/test.sh" ]; then \
			$(SOLVE_ANDROID)/$$proj/test.sh; \
		fi; \
	done

# Version upgrade target (for migration)
upgrade:
ifndef VER
	$(error VER must be specified for upgrade)
endif
	@echo "Upgrading to version $(VER)..."
	@for proj in $(SUBPROJECTS); do \
		$(MAKE) -C $(SOLVE_ANDROID)/$$proj upgrade VER=$(VER); \
	done
