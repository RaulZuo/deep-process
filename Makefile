# Build all by default, even if it's not first
.DEFAULT_GOAL := all

.PHONY: all
all: gen add-copyright format lint cover build
