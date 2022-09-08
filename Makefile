##
# nephelaiio.k8s Ansible role
#
# @file
# @version 0.0.1

KIND_RELEASE := $$(yq eval '.jobs.molecule.strategy.matrix.release| sort | reverse | .[0]' .github/workflows/main.yml)
KIND_IMAGE := $$(yq eval '.jobs.molecule.strategy.matrix.image | sort | reverse | .[0]' .github/workflows/main.yml)
ROLE_NAME := $$(pwd | xargs basename)
SCENARIO_NAME := default
EPHEMERAL_DIR := "$$HOME/.cache/molecule/$(ROLE_NAME)/$(SCENARIO_NAME)"

.PHONY: local aws poetry

test create converge verify destroy: poetry
	KIND_RELEASE=$(KIND_RELEASE) KIND_IMAGE=$(KIND_IMAGE) poetry run molecule $@

run:
	$(EPHEMERAL_DIR)/bwrap $(filter-out $@,$(MAKECMDGOALS))

helm:
	KUBECONFIG=$(EPHEMERAL_DIR)/config helm $(filter-out $@,$(MAKECMDGOALS))

kubectl:
	KUBECONFIG=$(EPHEMERAL_DIR)/config kubectl $(filter-out $@,$(MAKECMDGOALS))

poetry:
	@poetry install

%:
	@:

# end
