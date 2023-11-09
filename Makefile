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

.PHONY: test
test: ## run ANTA tests
	cd $(CURRENT_DIR)/atd-inventory/playbooks; ansible-playbook atd-validate-states.yml

.PHONY: start
start: ## Deploy ceos lab
	sudo containerlab deploy --debug --topo $(CURRENT_DIR)/clab/topology.clab.yml --max-workers 2 --timeout 5m --reconfigure

.PHONY: stop
stop: ## Destroy ceos lab
	sudo containerlab destroy --debug --topo $(CURRENT_DIR)/clab/topology.clab.yml --cleanup

.PHONY: save_anta_catalog
save_anta_catalog: ## save anta test catalog
	sed -i 's/catalog = Catalog(device_name, hostvars, skipped_tests=skipped_tests, custom_catalog_path=f"\/workspaces\/anta-malaga\/atd-inventory\/intended\/test_catalogs\/{device_name}-catalog.yml")/catalog = Catalog(device_name, hostvars, skipped_tests=skipped_tests)/g' /home/vscode/.ansible/collections/ansible_collections/arista/avd/plugins/plugin_utils/eos_validate_state_utils/get_anta_results.py
	cd $(CURRENT_DIR)/atd-inventory/playbooks; ansible-playbook atd-save-anta-catalog.yml

.PHONY: update_anta_catalog
update_anta_catalog: ## update anta test catalog
	sed -i 's/catalog = Catalog(device_name, hostvars, skipped_tests=skipped_tests)/catalog = Catalog(device_name, hostvars, skipped_tests=skipped_tests, custom_catalog_path=f"\/workspaces\/anta-malaga\/atd-inventory\/intended\/test_catalogs\/{device_name}-catalog.yml")/g' /home/vscode/.ansible/collections/ansible_collections/arista/avd/plugins/plugin_utils/eos_validate_state_utils/get_anta_results.py
	cd $(CURRENT_DIR)/atd-inventory/playbooks; ansible-playbook atd-validate-states.yml
