cluster-aws/common.tf: common/common.tf
	cp common/common.tf cluster-aws/common.tf

cluster-metal/common.tf: common/common.tf
	cp common/common.tf cluster-metal/common.tf

cluster-metal-gc/common.tf: common/common.tf
	cp common/common.tf cluster-metal-gc/common.tf

cluster-ps-cloud/common.tf: common/common.tf
	cp common/common.tf cluster-ps-cloud/common.tf

.PHONY: all
all: cluster-ps-cloud/common.tf cluster-metal/common.tf cluster-aws/common.tf cluster-metal-gc/common.tf
