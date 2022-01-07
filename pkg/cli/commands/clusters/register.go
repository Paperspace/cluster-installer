package clusters

import (
	"fmt"
	"github.com/Paperspace/gradient-installer/pkg/cli"
	"github.com/Paperspace/gradient-installer/pkg/cli/terraform"
	"github.com/Paperspace/paperspace-go"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/aws/aws-sdk-go/service/sts"
	"github.com/manifoldco/promptui"
	"github.com/pkg/errors"
	"github.com/spf13/cobra"
	"gopkg.in/yaml.v2"
	"os"
)

func createAWSStaticCredentialSession(AWSAccessKeyID string, AWSSecretAccessKey string, AWSRegion string) (*session.Session, error) {
	return session.NewSession(&aws.Config{
		Region:      aws.String(AWSRegion),
		Credentials: credentials.NewStaticCredentials(AWSAccessKeyID, AWSSecretAccessKey, ""),
	})
}

func validateAWSS3BucketExists(AWSAccessKeyID string, AWSSecretAccessKey string, AWSRegion string, AWSBucketName string) error {

	session, err := createAWSStaticCredentialSession(AWSAccessKeyID, AWSSecretAccessKey, AWSRegion)

	if err != nil {
		return err
	}

	svc := s3.New(session)

	_, err = svc.HeadBucket(&s3.HeadBucketInput{
		Bucket: aws.String(AWSBucketName),
	})

	return err
}

func getAWSSTSCallerArn(AWSAccessKeyID string, AWSSecretAccessKey string, AWSRegion string) (string, error) {

	session, err := createAWSStaticCredentialSession(AWSAccessKeyID, AWSSecretAccessKey, AWSRegion)

	if err != nil {
		return "", err
	}
	svc := sts.New(session)
	result, err := svc.GetCallerIdentity(&sts.GetCallerIdentityInput{})

	if err != nil {
		return "", err
	}

	return *result.Arn, err
}

func ClusterRegister(client *paperspace.Client, createFilePath string) (string, error) {
	var cluster paperspace.Cluster
	var params paperspace.ClusterCreateParams
	var region string

	if createFilePath == "" {
		awsRegionSelect := promptui.Select{
			Label: "AWS Region",
			Items: paperspace.ClusterAWSRegions,
		}
		artifactsAccessKeyIDPrompt := cli.Prompt{
			Label:    "Artifacts S3 Access Key ID",
			Required: true,
		}
		artifactsBucketPathPrompt := cli.Prompt{
			Label:    "Artifacts S3 Bucket",
			Required: true,
		}
		artifactsSecretAccessKeyPrompt := cli.Prompt{
			Label:    "Artifacts S3 Secret Access Key",
			Required: true,
			UseMask:  true,
		}
		domainPrompt := cli.Prompt{
			Label:    "Domain (gradient.mycompany.com)",
			Required: true,
		}
		namePrompt := cli.Prompt{
			Label:    "Name",
			Required: true,
		}
		platformSelect := promptui.Select{
			Label: "Platform",
			Items: terraform.SupportedClusterPlatformTypes,
		}
		println(cli.TextHeader("Register a private cluster"))
		if err := namePrompt.Run(); err != nil {
			return "", err
		}
		if err := domainPrompt.Run(); err != nil {
			return "", err
		}

		_, platform, err := platformSelect.Run()
		if err != nil {
			return "", err
		}
		if platform == string(paperspace.ClusterPlatformAWS) {
			_, region, err = awsRegionSelect.Run()
			if err != nil {
				return "", err
			}
		}
		if err := artifactsAccessKeyIDPrompt.Run(); err != nil {
			return "", err
		}
		if err := artifactsSecretAccessKeyPrompt.Run(); err != nil {
			return "", err
		}

		_, err = getAWSSTSCallerArn(artifactsAccessKeyIDPrompt.Value,
			artifactsSecretAccessKeyPrompt.Value,
			region,
		)
		if err != nil {
			return "", errors.New("Unable to validate your AWS identity from the specified credentials.")
		}

		if err := artifactsBucketPathPrompt.Run(); err != nil {
			return "", err
		}

		err = validateAWSS3BucketExists(artifactsAccessKeyIDPrompt.Value,
			artifactsSecretAccessKeyPrompt.Value,
			region,
			artifactsBucketPathPrompt.Value,
		)

		if err != nil {
			return "",
				errors.New(
					fmt.Sprintf("Unable to validate your S3 bucket %s from the specified credentials.", artifactsBucketPathPrompt.Value))
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
