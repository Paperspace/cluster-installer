package terraform

import "fmt"

type AWS struct {
	*Common
}

func NewAWS() *AWS {
	aws := AWS{
		Common: NewCommon(),
	}

	aws.TerraformSource = fmt.Sprintf("%s?ref=master/cluster-aws", SourcePrefix)
	return &aws
}
