

TERRAFORM_BIN := $(shell which terraform)

terraform_bin_path:
	@echo ${TERRAFORM_BIN}

.PHONY: bin_exists
bin_exists:
	stat ${TERRAFORM_BIN}

.PHONY: init
init:
	${TERRAFORM_BIN} init

.PHONY: plan
plan:
	${TERRAFORM_BIN} plan

fmt_module:
	cd ../ && ${TERRAFORM_BIN} fmt -recursive -write=true


