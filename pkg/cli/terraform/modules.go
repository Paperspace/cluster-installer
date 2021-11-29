package terraform

type TerraformModules struct {
	AWS   *AWS           `json:"gradient_aws,omitempty"`
	Metal *MetalPlatform `json:"gradient_metal,omitempty"`
}
