package terraform

import (
	"fmt"

	"github.com/Paperspace/paperspace-go"
)

type MetalPlatformNode struct {
	IP              string   `json:"ip"`
	InternalAddress string   `json:"internal-address,omitempty"`
	PoolName        string   `json:"pool-name"`
	PoolType        PoolType `json:"pool-type"`
}

type MetalPlatform struct {
	*Common
	MainNode            *MetalPlatformNode   `json:"k8s_master_node"`
	WorkerNodes         []*MetalPlatformNode `json:"k8s_workers"`
	RebootGPUNodes      bool                 `json:"reboot_gpu_nodes,omitempty"`
	Sans                []string             `json:"k8s_sans,omitempty"`
	SetupDocker         bool                 `json:"setup_docker,omitempty"`
	SetupNvidia         bool                 `json:"setup_nvidia,omitempty"`
	SharedStoragePath   string               `json:"shared_storage_path,omitempty"`
	SharedStorageServer string               `json:"shared_storage_server,omitempty"`
	SSHKeyPath          string               `json:"ssh_key_path,omitempty"`
	SSHUser             string               `json:"ssh_user,omitempty"`
}

func NewMetalPlatform(platform paperspace.ClusterPlatformType) *MetalPlatform {
	metalPlatform := MetalPlatform{
		Common:      NewCommon(),
		MainNode:    NewMetalPlatformNode(platform),
		WorkerNodes: make([]*MetalPlatformNode, 0),
		SSHKeyPath:  "", // TODO TOMS provide alternatives
		SSHUser:     "ubuntu",
	}

	metalPlatform.TerraformSource = fmt.Sprintf("%s?ref=master/cluster-metal", SourcePrefix)
	return &metalPlatform
}

func NewMetalPlatformNode(platform paperspace.ClusterPlatformType) *MetalPlatformNode {
	switch platform {
	case paperspace.ClusterPlatformGraphcore:
		return &MetalPlatformNode{
			PoolType: PoolTypeCPU,
		}
	case paperspace.ClusterPlatformSambaNova:
		return &MetalPlatformNode{
			PoolType: PoolTypeCPU,
		}
	}

	return &MetalPlatformNode{
		PoolType: PoolTypeGPU,
	}
}

func MetalPlatformPoolName(poolType PoolType, platform paperspace.ClusterPlatformType) string {
	switch platform {
	case paperspace.ClusterPlatformMetal:
		switch poolType {
		case PoolTypeCPU:
			return "metal-cpu"
		case PoolTypeGPU:
			return "metal-gpu"
		}
	case paperspace.ClusterPlatformDGX:
		switch poolType {
		case PoolTypeCPU:
			return "dgx.cpu"
		case PoolTypeGPU:
			return "dgx.gpu"
		}
	case paperspace.ClusterPlatformGraphcore:
		switch poolType {
		case PoolTypeCPU:
			return "ipu-host"
		case PoolTypeGPU:
			return ""
		}
	case paperspace.ClusterPlatformSambaNova:
		switch poolType {
		case PoolTypeCPU:
			return "rdu-node"
		case PoolTypeGPU:
			return ""
		}
	}

	return ""
}

func (m *MetalPlatformNode) UpdatePool(poolType PoolType, platform paperspace.ClusterPlatformType) {
	m.PoolType = poolType
	m.PoolName = MetalPlatformPoolName(poolType, platform)
}
