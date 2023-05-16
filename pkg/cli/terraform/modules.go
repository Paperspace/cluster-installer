package terraform

type TerraformModules struct {
	AWS   *AWS           `json:"cluster_aws,omitempty"`
	Metal *MetalPlatform `json:"cluster_metal,omitempty"`
}
