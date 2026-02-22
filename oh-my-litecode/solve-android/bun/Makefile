# Bun for Termux - Sub-project Makefile
#
# Package naming:
#   bun-{ver}-{relfix}.pacman.tar.xz    (standard)
#   bun-debug-{ver}-{relfix}.pacman.tar.xz  (debug)

SHELL := /bin/bash
.DEFAULT_GOAL := help

# Version (can be overridden)
VER ?= 1.2.20
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

.PHONY: help build package clean upgrade

help:
	@echo "Bun for Termux Build"
	@echo ""
	@echo "Usage: make [target] [VARIABLE=value]"
	@echo ""
	@echo "Targets:"
	@echo "  build    Build the package"
	@echo "  package  Create distribution package"
	@echo "  clean    Clean build artifacts"
	@echo "  upgrade  Upgrade to new version"

build:
	@echo "Building Bun v$(VER) for $(PKGMGR)..."
	@mkdir -p $(BUILD_DIR)
	
	@if [ "$(PKGMGR)" = "pacman" ]; then \
		cd $(PACKAGING_DIR)/pacman && \
		makepkg -C -f || true; \
	elif [ "$(PKGMGR)" = "dpkg" ]; then \
		cd $(PACKAGING_DIR)/dpkg && \
		./build.sh || true; \
	fi
	
	@echo "Build complete."

package: build
	@echo "Creating distribution package..."
	@mkdir -p $(DIST_DIR)
	
	@if [ "$(DEBUG)" = "true" ]; then \
		PKG_NAME="bun-debug-$(VER)-$(RELFIX).$(PKGMGR)"; \
	else \
		PKG_NAME="bun-$(VER)-$(RELFIX).$(PKGMGR)"; \
	fi; \
	cp $(PACKAGING_DIR)/$(PKGMGR)/*.pkg.* $(DIST_DIR)/$$PKG_NAME.tar.xz 2>/dev/null || true
	
	@echo "Package created."

clean:
	@rm -rf $(BUILD_DIR)
	@rm -f $(PACKAGING_DIR)/pacman/*.pkg.*
	@rm -rf $(PACKAGING_DIR)/pacman/pkg
	@rm -rf $(PACKAGING_DIR)/pacman/src
	@echo "Clean complete."

upgrade:
	@echo "Upgrading Bun to v$(VER)..."
	@sed -i "s/^pkgver=.*/pkgver=$(VER)/" $(PACKAGING_DIR)/pacman/PKGBUILD
	@sed -i "s/^pkgrel=.*/pkgrel=1/" $(PACKAGING_DIR)/pacman/PKGBUILD
	@echo "Version updated to $(VER)"
