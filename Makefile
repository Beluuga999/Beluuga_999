.PHONY: help tests

help:
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

deps: ## Install deps
	git submodule update --init --recursive
	make -C contracts deps
	go install github.com/maoueh/zap-pretty@latest

anvil-deploy-eigen-contracts: ## Deploy Eigen Layer contracts and dump to json file
	make -C contracts anvil-deploy-eigen-contracts

anvil-start: ## Start anvil
	make -C contracts anvil-start

