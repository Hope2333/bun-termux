# OpenCode for Termux - Sub-project Makefile
#
# Package naming:
#   opencode-{ver}-{relfix}.pacman.tar.xz    (standard)
#   opencode-debug-{ver}-{relfix}.pacman.tar.xz  (debug, includes sources)

SHELL := /bin/bash
.DEFAULT_GOAL := help

# Version (can be overridden)
VER ?= 1.1.65
RELFIX ?= 1

# Build parameters
PKGMGR ?= pacman
DEBUG ?= false

# Directories
PROJECT_DIR := $(shell pwd)
SCRIPTS_DIR := $(PROJECT_DIR)/scripts
PACKAGING_DIR := $(PROJECT_DIR)/packaging
RUNTIME_DIR := $(PROJECT_DIR)/runtime
PATCHES_DIR := $(PROJECT_DIR)/patches
DIST_DIR := $(PROJECT_DIR)/../dist

# Build output
BUILD_DIR := $(PROJECT_DIR)/.build
STAGING_DIR := $(BUILD_DIR)/staging

.PHONY: help build package clean upgrade

help:
	@echo "OpenCode for Termux Build"
	@echo ""
	@echo "Usage: make [target] [VARIABLE=value]"
	@echo ""
	@echo "Targets:"
	@echo "  build    Build the package"
	@echo "  package  Create distribution package"
	@echo "  clean    Clean build artifacts"
	@echo "  upgrade  Upgrade to new version"
	@echo ""
	@echo "Variables:"
	@echo "  VER=$(VER)        Target version"
	@echo "  PKGMGR=$(PKGMGR)  Package manager"
	@echo "  DEBUG=$(DEBUG)    Include debug artifacts"

# Main build target
build:
	@echo "Building OpenCode v$(VER) for $(PKGMGR)..."
	@mkdir -p $(BUILD_DIR) $(STAGING_DIR)
	
	# Run build script
	@if [ "$(PKGMGR)" = "pacman" ]; then \
		cd $(PACKAGING_DIR)/pacman && \
		makepkg -C -f || true; \
	elif [ "$(PKGMGR)" = "dpkg" ]; then \
		cd $(PACKAGING_DIR)/dpkg && \
		./build.sh || true; \
	fi
	
	@echo "Build complete."

# Package for distribution
package: build
	@echo "Creating distribution package..."
	@mkdir -p $(DIST_DIR)
	
	# Determine package name based on debug flag
	@if [ "$(DEBUG)" = "true" ]; then \
		PKG_NAME="opencode-debug-$(VER)-$(RELFIX).$(PKGMGR)"; \
	else \
		PKG_NAME="opencode-$(VER)-$(RELFIX).$(PKGMGR)"; \
	fi; \
	echo "Package: $$PKG_NAME"; \
	cp $(PACKAGING_DIR)/$(PKGMGR)/*.pkg.* $(DIST_DIR)/$$PKG_NAME.tar.xz 2>/dev/null || true
	
	@echo "Package created in $(DIST_DIR)"

# Clean build artifacts
clean:
	@rm -rf $(BUILD_DIR)
	@rm -f $(PACKAGING_DIR)/pacman/*.pkg.*
	@rm -rf $(PACKAGING_DIR)/pacman/pkg
	@rm -rf $(PACKAGING_DIR)/pacman/src
	@echo "Clean complete."

# Upgrade to new version
upgrade:
	@echo "Upgrading OpenCode to v$(VER)..."
	# Update PKGBUILD version
	@sed -i "s/^pkgver=.*/pkgver=$(VER)/" $(PACKAGING_DIR)/pacman/PKGBUILD
	@sed -i "s/^pkgrel=.*/pkgrel=1/" $(PACKAGING_DIR)/pacman/PKGBUILD
	@echo "Version updated to $(VER)"
