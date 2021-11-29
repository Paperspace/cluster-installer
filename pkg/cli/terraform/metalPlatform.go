package terraform

import (
	"fmt"

	"github.com/Paperspace/paperspace-go"
)

type MetalNode struct {
	IP              string   `json:"ip"`
	InternalAddress string   `json:"internal-address,omitempty"`
	PoolName        string   `json:"pool-name"`
	PoolType        PoolType `json:"pool-type"`
}

type Metal struct {
	*Common
	MainNode            *MetalNode   `json:"k8s_master_node"`
	WorkerNodes         []*MetalNode `json:"k8s_workers"`
	RebootGPUNodes      bool         `json:"reboot_gpu_nodes,omitempty"`
	Sans                []string     `json:"k8s_sans,omitempty"`
	SetupDocker         bool         `json:"setup_docker,omitempty"`
	SetupNvidia         bool         `json:"setup_nvidia,omitempty"`
	SharedStoragePath   string       `json:"shared_storage_path,omitempty"`
	SharedStorageServer string       `json:"shared_storage_server,omitempty"`
	SSHKeyPath          string       `json:"ssh_key_path,omitempty"`
	SSHUser             string       `json:"ssh_user,omitempty"`
}

func NewMetal(platform paperspace.ClusterPlatformType) *Metal {
	metal := Metal{
		Common:      NewCommon(),
		MainNode:    NewMetalNode(platform),
		WorkerNodes: make([]*MetalNode, 0),
		SSHKeyPath:  "~/.ssh/id_rsa",
		SSHUser:     "ubuntu",
	}

	metal.TerraformSource = fmt.Sprintf("%s?ref=master/gradient-metal", SourcePrefix)
	return &metal
}

func NewMetalNode(platform paperspace.ClusterPlatformType) *MetalNode {
	switch platform {
	case paperspace.ClusterPlatformGraphcore:
		return &MetalNode{
			PoolType: PoolTypeCPU,
		}
	case paperspace.ClusterPlatformSambaNova:
		return &MetalNode{
			PoolType: PoolTypeCPU,
		}
	}

	return &MetalNode{
		PoolType: PoolTypeGPU,
	}
}

func MetalPoolName(poolType PoolType, platform paperspace.ClusterPlatformType) string {
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

func (m *MetalNode) UpdatePool(poolType PoolType, platform paperspace.ClusterPlatformType) {
	m.PoolType = poolType
	m.PoolName = MetalPoolName(poolType, platform)
}
