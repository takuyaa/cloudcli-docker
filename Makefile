# Makefile for CloudCLI

# Variables
REGISTRY := ghcr.io
USERNAME := takuyaa
IMAGE_NAME := cloudcli
VERSION ?= $(error VERSION is required. Usage: make build VERSION=v1.16.4)

# Derived variables
IMAGE := $(REGISTRY)/$(USERNAME)/$(IMAGE_NAME)
BUILD_ARGS := --build-arg CLOUDCLI_VERSION=$(VERSION)

.PHONY: help
help: ## Show this help message
	@echo 'Usage: make [target] VERSION=<version>'
	@echo ''
	@echo 'Required variable:'
	@echo '  VERSION         CloudCLI UI version (e.g., v1.16.4)'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

.PHONY: build
build: ## Build Docker image (requires VERSION=)
	docker build $(BUILD_ARGS) \
		-t $(IMAGE):$(VERSION) \
		-t $(IMAGE):latest \
		.

.PHONY: push
push: ## Push Docker image to registry
	docker push $(IMAGE):$(VERSION)
	docker push $(IMAGE):latest

.PHONY: build-push
build-push: build push ## Build and push Docker image

.PHONY: login
login: ## Login to GitHub Container Registry
	@echo "$$GITHUB_TOKEN" | docker login $(REGISTRY) -u $(USERNAME) --password-stdin

.PHONY: clean
clean: ## Clean local Docker images
	docker rmi $(IMAGE):$(VERSION) $(IMAGE):latest || true
