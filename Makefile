.PHONY: proto build install test clean init

PACKAGES=$(shell go list ./... | grep -v '/vendor/')
BUILDDIR ?= $(CURDIR)/build
DOCKER := $(shell which docker)

export GO111MODULE = on

###############################################################################
###                                Build                                    ###
###############################################################################

build: go.sum
	@echo "Building shahd..."
	mkdir -p $(BUILDDIR)
	go build -mod=readonly -o $(BUILDDIR)/shahd ./cmd/shahd

install: go.sum
	@echo "Installing shahd..."
	go install -mod=readonly ./cmd/shahd

go.sum: go.mod
	@echo "--> Ensure dependencies have not been modified"
	go mod verify
	go mod tidy

clean:
	rm -rf $(BUILDDIR)

###############################################################################
###                                Protobuf                                 ###
###############################################################################

proto:
	@echo "Generating protobuf files..."
	@if ! command -v buf >/dev/null 2>&1; then \
		echo "buf is not installed. Please install buf: https://buf.build/docs/installation"; \
		exit 1; \
	fi
	buf generate

proto-format:
	@echo "Formatting protobuf files..."
	find proto -name '*.proto' -path "*/proto/shahcoin/*" -exec clang-format -i {} \;

###############################################################################
###                                Testing                                  ###
###############################################################################

test:
	@echo "Running tests..."
	go test -mod=readonly $(PACKAGES)

test-race:
	@echo "Running tests with race detection..."
	go test -mod=readonly -race $(PACKAGES)

###############################################################################
###                               Initialize                                ###
###############################################################################

init:
	@echo "Initializing genesis..."
	./scripts/init_genesis.sh

###############################################################################
###                                 Lint                                    ###
###############################################################################

lint:
	@echo "Running linters..."
	golangci-lint run --timeout=10m

format:
	@echo "Formatting code..."
	gofmt -w .
	goimports -w .

###############################################################################
###                                 Help                                    ###
###############################################################################

help:
	@echo "Shahcoin Makefile commands:"
	@echo ""
	@echo "  make build          - Build the shahd binary"
	@echo "  make install        - Install shahd to GOBIN"
	@echo "  make proto          - Generate protobuf files"
	@echo "  make test           - Run tests"
	@echo "  make clean          - Remove build directory"
	@echo "  make init           - Initialize genesis (run init_genesis.sh)"
	@echo "  make lint           - Run linters"
	@echo "  make format         - Format code"

