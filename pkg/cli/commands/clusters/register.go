package clusters

import (
	"fmt"
	"github.com/Paperspace/gradient-installer/pkg/cli"
	"github.com/Paperspace/gradient-installer/pkg/cli/terraform"
	"github.com/Paperspace/paperspace-go"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sts"
	"github.com/manifoldco/promptui"
	"github.com/spf13/cobra"
	"gopkg.in/yaml.v2"
	"os"
)

func verifySTSCallerIdentity(AWSAccessKeyID string, AWSSecretAccessKey string, AWSRegion string) (string, bool, error) {

	session, err := session.NewSession(&aws.Config{
		Region:      aws.String(AWSRegion),
		Credentials: credentials.NewStaticCredentials(AWSAccessKeyID, AWSSecretAccessKey, ""),
	})

	if err != nil {
		return "", false, err
	}
	svc := sts.New(session)
	result, err := svc.GetCallerIdentity(&sts.GetCallerIdentityInput{})

	if err != nil {
		return "", false, err
	}

	return *result.Arn, true, err
}

func ClusterRegister(client *paperspace.Client, createFilePath string) (string, error) {
	var cluster paperspace.Cluster
	var params paperspace.ClusterCreateParams

	if createFilePath == "" {

		// Select AWS Region
		awsRegionSelect := promptui.Select{
			Label: "AWS Region",
			Items: paperspace.ClusterAWSRegions,
		}

		_, region, err := awsRegionSelect.Run()
		if err != nil {
			return "", err
		}

		// Input AWS ACCESS_KEY_ID and SECRET_ACCCESS_KEY
		artifactsAccessKeyIDPrompt := cli.Prompt{
			Label:    "Artifacts S3 Access Key ID",
			Required: true,
		}

		if err := artifactsAccessKeyIDPrompt.Run(); err != nil {
			return "", err
		}

		artifactsSecretAccessKeyPrompt := cli.Prompt{
			Label:    "Artifacts S3 Secret Access Key",
			Required: true,
			UseMask:  true,
		}

		if err := artifactsSecretAccessKeyPrompt.Run(); err != nil {
			return "", err
		}

		arn, stsValidated, err := verifySTSCallerIdentity(artifactsAccessKeyIDPrompt.Value,
			artifactsSecretAccessKeyPrompt.Value,
			region,
		)

		if err != nil || !stsValidated {
			println(fmt.Sprintf("Unable to validate AWS identity from credentails: %s", err))
			return "", err
		} else {
			println(fmt.Sprintf("AWS Identity is for: %s", arn))
		}

		// Input object store bucket for artifacts
		artifactsBucketPathPrompt := cli.Prompt{
			Label:    "Artifacts S3 Bucket",
			Required: true,
		}

		if err := artifactsBucketPathPrompt.Run(); err != nil {
			return "", err
		}

		domainPrompt := cli.Prompt{
			Label:    "Domain (gradient.mycompany.com)",
			Required: true,
		}

		if err := domainPrompt.Run(); err != nil {
			return "", err
		}

		namePrompt := cli.Prompt{
			Label:    "Name",
			Required: true,
		}

		if err := namePrompt.Run(); err != nil {
			return "", err
		}

		platformSelect := promptui.Select{
			Label: "Platform",
			Items: terraform.SupportedClusterPlatformTypes,
		}

		println(cli.TextHeader("Register a private cluster"))
		_, platform, err := platformSelect.Run()
		if err != nil {
			return "", err
		}

		params = paperspace.ClusterCreateParams{
			ArtifactsAccessKeyID:     artifactsAccessKeyIDPrompt.Value,
			ArtifactsBucketPath:      artifactsBucketPathPrompt.Value,
			ArtifactsSecretAccessKey: artifactsSecretAccessKeyPrompt.Value,
			Domain:                   domainPrompt.Value,
			Name:                     namePrompt.Value,
			Platform:                 platform,
			Region:                   region,
		}
	} else {
		createFile, err := os.Open(createFilePath)
		defer createFile.Close()
		if err != nil {
			return "", err
		}

		decoder := yaml.NewDecoder(createFile)
		err = decoder.Decode(&params)
		if err != nil {
			return "", err
		}
	}
	cluster, err := client.CreateCluster(params)
	if err != nil {
		return "", err
	}

	println(fmt.Sprintf("Cluster created with ID: %s", cluster.ID))
	println(fmt.Sprintf("Cluster API key: %s", cluster.APIToken.Key))

	return cluster.ID, nil
}

func NewClusterRegisterCommand() *cobra.Command {
	var createFilePath string

	command := cobra.Command{
		Use:   "register",
		Short: "Register a new private cluster",
		RunE: func(cmd *cobra.Command, args []string) error {
			client := cli.FromContext(cmd)
			_, err := ClusterRegister(client, createFilePath)
			if err != nil {
				return err
			}
			return nil
		},
	}
	command.Flags().StringVarP(&createFilePath, "file", "f", "", "YAML file to create a cluster")

	return &command
}
