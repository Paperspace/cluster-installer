gradient-aws/common.tf: common/common.tf
	cp common/common.tf gradient-aws/common.tf

gradient-metal/common.tf: common/common.tf
	cp common/common.tf gradient-metal/common.tf

gradient-metal-gc/common.tf: common/common.tf
	cp common/common.tf gradient-metal-gc/common.tf

gradient-ps-cloud/common.tf: common/common.tf
	cp common/common.tf gradient-ps-cloud/common.tf

.PHONY: all
all: gradient-ps-cloud/common.tf gradient-metal/common.tf gradient-aws/common.tf gradient-metal-gc/common.tf
