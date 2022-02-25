

TERRAFORM_BIN := $(shell which terraform)

terraform_bin_path:
	@echo ${TERRAFORM_BIN}

.PHONY: bin_exists
bin_exists:
	stat ${TERRAFORM_BIN}

.PHONY: init
init:
	${TERRAFORM_BIN} init


