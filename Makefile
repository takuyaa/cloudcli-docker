# Makefile for CloudCLI

# Variables
REGISTRY := ghcr.io
USERNAME := takuyaa
IMAGE_NAME := cloudcli
PLATFORMS := linux/amd64,linux/arm64

# Derived variables
IMAGE := $(REGISTRY)/$(USERNAME)/$(IMAGE_NAME)

# VERSION is required for build targets (checked in each target)
ifdef VERSION
BUILD_ARGS := --build-arg CLOUDCLI_VERSION=$(VERSION)
endif

.PHONY: help
help: ## Show this help message
	@echo 'CloudCLI Docker Build'
	@echo ''
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

.PHONY: setup
setup: ## Setup buildx builder for multi-arch (first-time setup)
	docker buildx create --name multiarch --use || docker buildx use multiarch
	docker buildx inspect --bootstrap

.PHONY: build
build: ## Build and push multi-arch image (requires VERSION=)
ifndef VERSION
	$(error VERSION is required. Usage: make build VERSION=v1.17.1)
endif
	docker buildx build $(BUILD_ARGS) \
		--platform $(PLATFORMS) \
		-t $(IMAGE):$(VERSION) \
		-t $(IMAGE):latest \
		--push \
		.

.PHONY: build-local
build-local: ## Build local image for testing (requires VERSION=)
ifndef VERSION
	$(error VERSION is required. Usage: make build-local VERSION=v1.17.1)
endif
	docker build $(BUILD_ARGS) \
		-t $(IMAGE):$(VERSION) \
		-t $(IMAGE):latest \
		.

.PHONY: login
login: ## Login to GitHub Container Registry
	@echo "$$GITHUB_TOKEN" | docker login $(REGISTRY) -u $(USERNAME) --password-stdin

.PHONY: clean
clean: ## Clean local Docker images (requires VERSION=)
ifndef VERSION
	$(error VERSION is required. Usage: make clean VERSION=v1.17.1)
endif
	docker rmi $(IMAGE):$(VERSION) $(IMAGE):latest || true
