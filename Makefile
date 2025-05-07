.PHONY: ${MAKECMDGOALS}

K8S_RELEASE := $$(yq eval '.jobs.molecule.strategy.matrix.k8s[0]' .github/workflows/molecule.yml)
ROLE_NAME := $$(pwd | xargs basename)
MOLECULE_SCENARIO ?= default
MOLECULE_EPHEMERAL_DIR := $$HOME/.cache/molecule/$(ROLE_NAME)/$(MOLECULE_SCENARIO)
KUBECONFIG := ${MOLECULE_EPHEMERAL_DIR}/config
PG_DB := $$(yq eval '.provisioner.inventory.hosts.all.vars.zalando_db' molecule/default/molecule.yml -r)
PG_NS := $$(yq eval '.provisioner.inventory.hosts.all.vars.zalando_namespace' molecule/default/molecule.yml -r)
PG_TEAM := $$(yq eval '.provisioner.inventory.hosts.all.vars.zalando_team' molecule/default/molecule.yml -r)
PG_USER := $$(yq eval '.provisioner.inventory.hosts.all.vars.zalando_user' molecule/default/molecule.yml -r)
PG_PASS := $$(make --no-print-directory kubectl get secret $(PG_USER)-$(PG_TEAM)-$(PG_DB) -- -n $(PG_NS) -o json | jq '.data.password' -r | base64 -d )
PG_HOST := $$(make --no-print-directory kubectl get service -- -n $(PG_NS) -o json | jq ".items | map(select(.metadata.name == \"$(PG_TEAM)-$(PG_DB)\"))[0] | .status.loadBalancer.ingress[0].ip" -r)
GITHUB_ORG = $$(echo ${GITHUB_REPOSITORY} | cut -d/ -f 1)
GITHUB_REPO = $$(echo ${GITHUB_REPOSITORY} | cut -d/ -f 2)

install:
	@poetry install --no-root

lint: install
	poetry run yamllint .
	poetry run ansible-lint .
	poetry run molecule syntax

test dependency create prepare converge idempotence side-effect verify destroy login reset list:
	K8S_RELEASE=$(K8S_RELEASE) \
	MOLECULE_EPHEMERAL_DIRECTORY=$(MOLECULE_EPHEMERAL_DIR)	\
	KUBECONFIG=$(KUBECONFIG) \
	  poetry run molecule $@ -s $(MOLECULE_SCENARIO)

rebuild: destroy prepare create

ignore:
	poetry run ansible-lint --generate-ignore

clean:
	@find ${HOME}/.cache/ansible-compat/ -mindepth 2 -maxdepth 2 -type d -name "roles" | xargs -r rm -rf
	@poetry env remove $$(which python) >/dev/null 2>&1 || exit 0

update:
	@bin/update_charts

publish:
	@echo publishing repository ${GITHUB_REPOSITORY}
	@echo GITHUB_ORGANIZATION=${GITHUB_ORG}
	@echo GITHUB_REPOSITORY=${GITHUB_REPO}
	@poetry run ansible-galaxy role import \
		--api-key ${GALAXY_API_KEY} ${GITHUB_ORG} ${GITHUB_REPO}

version:
	@poetry run molecule --version

run:
	$(MOLECULE_EPHEMERAL_DIR)/bwrap $(filter-out $@,$(MAKECMDGOALS))

ifeq (helm,$(firstword $(MAKECMDGOALS)))
    HELM_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
    $(eval $(subst $(space),,$(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))):;@:)
endif

helm:
	KUBECONFIG=$(KUBECONFIG) $@ $(HELM_ARGS)

ifeq (kubectl,$(firstword $(MAKECMDGOALS)))
    KUBECTL_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
    $(eval $(subst $(space),,$(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))):;@:)
endif

kubectl:
	KUBECONFIG=$(KUBECONFIG) $@ $(KUBECTL_ARGS)

psql:
	PGPASSWORD=$(PG_PASS) psql -h $(PG_HOST) -U $(PG_USER) $(PG_DB)
