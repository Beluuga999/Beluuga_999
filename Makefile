.PHONY: help tests

CONFIG_FILE?=config-files/config.yaml

help:
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

deps: ## Install deps
	git submodule update --init --recursive
	go install github.com/maoueh/zap-pretty@latest

install-foundry:
	curl -L https://foundry.paradigm.xyz | bash

install-eigenlayer-cli:
	@go install github.com/Layr-Labs/eigenlayer-cli/cmd/eigenlayer@latest

anvil-deploy-eigen-contracts:
	@echo "Deploying Eigen Contracts..."
	. contracts/scripts/anvil/deploy_eigen_contracts.sh

anvil-deploy-mock-strategy:
	@echo "Deploying Mock Strategy..."
	. contracts/scripts/anvil/deploy_mock_strategy.sh

anvil-deploy-aligned-contracts:
	@echo "Deploying Aligned Contracts..."
	. contracts/scripts/anvil/deploy_aligned_contracts.sh

anvil-start:
	@echo "Starting Anvil..."
	anvil --load-state contracts/scripts/anvil/state/alignedlayer-deployed-anvil-state.json 

# TODO: Allow enviroment variables / different configuration files
aggregator-start:
	@echo "Starting Aggregator..."
	@go run aggregator/cmd/main.go --config config-files/config.yaml

aggregator-send-dummy-responses:
	@echo "Sending dummy responses to Aggregator..."
	@cd aggregator && go run dummy/submit_task_responses.go

operator-start:
	@echo "Starting Operator..."
	go run operator/cmd/main.go --config $(CONFIG_FILE) \
	2>&1 | zap-pretty

bindings:
	cd contracts && ./generate-go-bindings.sh

test:
	go test ./...


get-delegation-manager-address:
	@sed -n 's/.*"delegationManager": "\([^"]*\)".*/\1/p' contracts/script/output/devnet/eigenlayer_deployment_output.json

operator-generate-keys:
	@echo "Generating BLS keys"
	eigenlayer operator keys create --key-type bls --insecure operator
	@echo "Generating ECDSA keys"
	eigenlayer operator keys create --key-type ecdsa --insecure operator

operator-generate-config:
	@echo "Generating operator config"
	eigenlayer operator config create

operator-get-eth:
	@echo "Sending funds to operator address on devnet"
	@. ./scripts/fund_operator_devnet.sh

operator-register-with-eigen-layer:
	@echo "Registering operator with EigenLayer"
	@echo "" | eigenlayer operator register $(CONFIG_FILE)

operator-mint-mock-tokens:
	@echo "Minting tokens"
	. ./scripts/mint_mock_token.sh $(CONFIG_FILE) 1000

operator-deposit-into-mock-strategy:
	@echo "Depositing into strategy"
	$(eval STRATEGY_ADDRESS = $(shell jq -r '.erc20MockStrategy' contracts/script/output/devnet/strategy_deployment_output.json))

	@go run operator/scripts/deposit_into_strategy/main.go \
		--config $(CONFIG_FILE) \
		--strategy-address $(STRATEGY_ADDRESS) \
		--amount 1000

operator-deposit-into-strategy:
	@echo "Depositing into strategy"
	@go run operator/scripts/deposit_into_strategy/main.go \
		--config $(CONFIG_FILE) \
		--amount 1000

operator-register-with-aligned-layer:
	@echo "Registering operator with AlignedLayer"
	@go run operator/scripts/register_with_aligned_layer/main.go \
		--config $(CONFIG_FILE)

operator-deposit-and-register: operator-deposit-into-strategy operator-register-with-aligned-layer

operator-full-registration: operator-get-eth operator-register-with-eigen-layer operator-mint-mock-tokens operator-deposit-into-mock-strategy operator-register-with-aligned-layer

__TASK_SENDERS__:
send-plonk-proof: ## Send a PLONK proof using the task sender
	go run task_sender/cmd/main.go send-task \
		--proving-system plonk \
		--proof task_sender/test_examples/plonk.proof \
		--public-input task_sender/test_examples/plonk_pub_input.pub \
		--verification-key task_sender/test_examples/plonk.vk \
		--config config-files/config.yaml \
		2>&1 | zap-pretty

send-plonk-proof-loop: ## Send a PLONK proof using the task sender every 10 seconds
	go run task_sender/cmd/main.go loop-tasks \
		--proving-system plonk \
		--proof task_sender/test_examples/plonk.proof \
		--public-input task_sender/test_examples/plonk_pub_input.pub \
		--verification-key task_sender/test_examples/plonk.vk \
		--config config-files/config.yaml \
		--interval 10 \ 
		2>&1 | zap-pretty

__DEPLOYMENT__:
deploy-aligned-contracts: ## Deploy Aligned Contracts
	@echo "Deploying Aligned Contracts..."
	@. contracts/scripts/.env && . contracts/scripts/deploy_aligned_contracts.sh

build-aligned-contracts:
	@cd contracts/src/core && forge build
