CURRENT_DIR := $(shell pwd)

.PHONY: help
help: ## Display help message
	@grep -E '^[0-9a-zA-Z_-]+\.*[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: ## Generate AVD configs
	cd $(CURRENT_DIR)/atd-inventory/playbooks; ansible-playbook atd-fabric-build.yml

.PHONY: deploy
deploy: ## Deploy AVD configs using eAPI
	cd $(CURRENT_DIR)/atd-inventory/playbooks; ansible-playbook atd-fabric-provision-eapi.yml

.PHONY: validate
validate: ## run ANTA tests with AVD preview
	cd $(CURRENT_DIR)/atd-inventory/playbooks; ansible-playbook atd-validate-states.yml

.PHONY: start
start: ## Deploy ceos lab
	sudo containerlab deploy --debug --topo $(CURRENT_DIR)/clab/topology.clab.yml --max-workers 2 --timeout 5m --reconfigure

.PHONY: stop
stop: ## Destroy ceos lab
	sudo containerlab destroy --debug --topo $(CURRENT_DIR)/clab/topology.clab.yml --cleanup

.PHONY: build_anta_inventory
build_anta_inventory: ## Build ANTA inventory from AVD
	python3 build_anta_inventory.py

.PHONY: test
test: ## run ANTA test directly
	anta --username arista --password ${LABPASSPHRASE} --inventory anta-inventory.yml nrfu --catalog anta-catalog.yml table --tags fabric
