# Bun for Termux Makefile

SHELL := /bin/bash
.DEFAULT_GOAL := help

PKGVER ?= 1.3.9
PKGREL ?= 1
DEBUG ?= false
PKGMGR ?= pacman
ARCH ?= aarch64
DISTROVER ?= termux

PROJECT_DIR := $(shell pwd)
BUILD_DIR := $(PROJECT_DIR)/.build
DIST_DIR := $(PROJECT_DIR)/dist
RUNTIME_DIR := $(PROJECT_DIR)/runtime

ifeq ($(PKGMGR),pacman)
    ARCH_NAME := $(ARCH)
    PKG_EXT := .pkg.tar.xz
else
    ARCH_NAME := $(subst aarch64,arm64,$(ARCH))
    PKG_EXT := .deb
endif

PKG_NAME := bun-$(PKGVER)-$(PKGREL)-$(ARCH_NAME)$(PKG_EXT)

.PHONY: help build package clean

help:
	@echo "Bun for Termux Build"
	@echo ""
	@echo "Usage: make [target] [VARIABLE=value]"
	@echo ""
	@echo "Targets: build package clean"
	@echo "Variables: PKGVER=$(PKGVER) PKGREL=$(PKGREL)"

build:
	@echo "Building bun v$(PKGVER)..."
	@mkdir -p $(BUILD_DIR)

package: build
	@echo "Creating package: $(PKG_NAME)"
	@mkdir -p $(DIST_DIR)
	@if [ "$(PKGMGR)" = "pacman" ]; then \
		cd packaging/pacman && makepkg -C -f; \
		cp *.pkg.tar.xz $(DIST_DIR)/$(PKG_NAME) 2>/dev/null || true; \
	fi

clean:
	@rm -rf $(BUILD_DIR) $(DIST_DIR)
	@rm -f packaging/pacman/*.pkg.tar.*
	@echo "Clean complete."
