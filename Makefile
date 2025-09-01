# Makefile for whk - Webhook Manager

# Variables
PREFIX ?= /usr/local
BINDIR ?= $(HOME)/.local/bin
DATADIR ?= ~/.whk

# Default target
.PHONY: all
all: install

# Install the tool
.PHONY: install
install:
	@echo "Installing whk..."
	@mkdir -p $(BINDIR)
	@cp bin/whk $(BINDIR)/
	@cp bin/utils.sh $(BINDIR)/
	@chmod +x $(BINDIR)/whk
	@chmod +x $(BINDIR)/utils.sh
	@echo "whk installed to $(BINDIR)/whk"
	@echo "Creating data directory at $(DATADIR)..."
	@mkdir -p $(DATADIR)/logs
	@touch $(DATADIR)/webhooks
	@echo "Installation complete!"

# Run tests
.PHONY: test
test:
	@echo "Running tests..."
	@bash tests/simple_test_whk.sh

# Clean logs and temporary files
.PHONY: clean
clean:
	@echo "Cleaning logs and temporary files..."
	@rm -f $(DATADIR)/logs/whk.log
	@echo "Clean complete!"

# Uninstall the tool
.PHONY: uninstall
uninstall:
	@echo "Uninstalling whk..."
	@rm -f $(BINDIR)/whk
	@echo "whk uninstalled from $(BINDIR)/whk"
	@echo "Note: Data directory at $(DATADIR) is preserved"
	@echo "Uninstallation complete!"