package clusters

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"path/filepath"

	"github.com/Paperspace/cluster-installer/pkg/cli"
	"github.com/Paperspace/cluster-installer/pkg/cli/config"
	"github.com/Paperspace/cluster-installer/pkg/cli/terraform"
	"github.com/Paperspace/paperspace-go"
	"github.com/manifoldco/promptui"
	"github.com/spf13/cobra"
)

var TerraformTFName = "main.tf"

func createTerraformMetalPlatformNode(terraformMetalPlatformNode *terraform.MetalPlatformNode, platform paperspace.ClusterPlatformType,
	prefix string, required bool) (*terraform.MetalPlatformNode, error) {
	if terraformMetalPlatformNode == nil {
		terraformMetalPlatformNode = terraform.NewMetalPlatformNode(platform)
	}

	ipPrompt := cli.Prompt{
		Label:    "IP",
		Value:    terraformMetalPlatformNode.IP,
		Required: required,
	}

	internalAddressPrompt := cli.Prompt{
		Label: "Internal IP (if applicable)",
		Value: terraformMetalPlatformNode.InternalAddress,
	}

	var items []string
	switch platform {
	case paperspace.ClusterPlatformGraphcore,
		paperspace.ClusterPlatformSambaNova:
		items = []string{string(terraform.PoolTypeCPU)}
	default:
		items = []string{string(terraform.PoolTypeGPU), string(terraform.PoolTypeCPU)}
	}
	poolTypeSelect := promptui.Select{
		Label: "Type",
		Items: items,
	}

	println("")
	println(cli.TextHeader(fmt.Sprintf("Add %s", prefix)))

	if err := ipPrompt.Run(); err != nil {
		return terraformMetalPlatformNode, err
	}
	if err := internalAddressPrompt.Run(); err != nil {
		return terraformMetalPlatformNode, err
	}
	_, poolType, err := poolTypeSelect.Run()
	if err != nil {
		return terraformMetalPlatformNode, err
	}

	terraformMetalPlatformNode.IP = ipPrompt.Value
	terraformMetalPlatformNode.InternalAddress = internalAddressPrompt.Value
	terraformMetalPlatformNode.UpdatePool(terraform.PoolType(poolType), platform)

	return terraformMetalPlatformNode, nil
}

func setupMetalConfig(terraformMetalPlatform *terraform.MetalPlatform, platform paperspace.ClusterPlatformType) error {
	var platformHasGPU bool
	switch platform {
	case paperspace.ClusterPlatformGraphcore,
		paperspace.ClusterPlatformSambaNova:
		platformHasGPU = false
	default:
		platformHasGPU = true
	}
	// Typed to NFS till we support more storage types
	sharedStorageServer := cli.Prompt{
		Label:    "NFS Server",
		Required: true,
		Value:    terraformMetalPlatform.SharedStorageServer,
	}
	sharedStoragePath := cli.Prompt{
		Label:    "NFS Storage Path",
		Required: true,
		Value:    terraformMetalPlatform.SharedStoragePath,
	}
	setupDockerPrompt := cli.Prompt{
		Label:         "Setup Docker",
		Required:      true,
		AllowedValues: cli.YesNoValues,
		Value:         cli.BoolToYesNo(terraformMetalPlatform.SetupDocker),
	}
	var rebootGPUNodesPrompt cli.Prompt
	var setupNvidiaPrompt cli.Prompt
	if platformHasGPU {
		setupNvidiaPrompt = cli.Prompt{
			Label:    "Setup NVIDIA",
			Required: true,
			Value:    cli.BoolToYesNo(terraformMetalPlatform.SetupNvidia),
		}
		rebootGPUNodesPrompt = cli.Prompt{
			Label:         "Reboot GPU Nodes (for NVIDIA drivers)",
			AllowedValues: cli.YesNoValues,
			Value:         cli.BoolToYesNo(terraformMetalPlatform.RebootGPUNodes),
			Required:      true,
		}
	}

	sshKeyPathPrompt := cli.Prompt{
		Label:    "SSH Private Key Path",
		Required: false,
		Value:    terraformMetalPlatform.SSHKeyPath,
	}
	sshUserPrompt := cli.Prompt{
		Label:    "SSH User",
		Required: true,
		Value:    terraformMetalPlatform.SSHUser,
	}
	if err := sharedStorageServer.Run(); err != nil {
		return err
	}
	if err := sharedStoragePath.Run(); err != nil {
		return err
	}

	mainNode, err := createTerraformMetalPlatformNode(terraformMetalPlatform.MainNode, platform, "Main Node", true)
	if err != nil {
		return err
	}

	workerNodes := make([]*terraform.MetalPlatformNode, 0)

	for index, workerNode := range terraformMetalPlatform.WorkerNodes {
		workerPrompt := cli.Prompt{
			Label:         fmt.Sprintf("Remove worker node %d with IP: %s?", index+1, workerNode.IP),
			HideValue:     true,
			Required:      true,
			AllowedValues: cli.YesNoValues,
		}

		println("")
		if err := workerPrompt.Run(); err != nil {
			return err
		}

		if workerPrompt.Value == "yes" {
			continue
		}

		node, err := createTerraformMetalPlatformNode(workerNode, platform, fmt.Sprintf("Worker Node %d", index+1), true)
		if err != nil {
			return err
		}

		workerNodes = append(workerNodes, node)
	}

	for {
		workerPrompt := cli.Prompt{
			Label:         "Add a worker node?",
			Required:      true,
			HideValue:     true,
			AllowedValues: cli.YesNoValues,
		}

		println("")
		if err := workerPrompt.Run(); err != nil {
			return err
		}

		if workerPrompt.Value == "no" {
			break
		}

		node, err := createTerraformMetalPlatformNode(nil, platform, fmt.Sprintf("Worker Node %d", len(workerNodes)+1), true)
		if err != nil {
			return err
		}

		workerNodes = append(workerNodes, node)
	}

	if err := sshUserPrompt.Run(); err != nil {
		return err
	}
	if err := sshKeyPathPrompt.Run(); err != nil {
		return err
	}
	if err := setupDockerPrompt.Run(); err != nil {
		return err
	}
	if platformHasGPU {
		if err := setupNvidiaPrompt.Run(); err != nil {
			return err
		}

		terraformMetalPlatform.SetupNvidia = cli.YesNoToBool(setupNvidiaPrompt.Value)
	}

	terraformMetalPlatform.MainNode = mainNode
	terraformMetalPlatform.WorkerNodes = workerNodes
	terraformMetalPlatform.SharedStoragePath = sharedStoragePath.Value
	terraformMetalPlatform.SharedStorageServer = sharedStorageServer.Value
	terraformMetalPlatform.SetupDocker = cli.YesNoToBool(setupDockerPrompt.Value)
	terraformMetalPlatform.SSHKeyPath = sshKeyPathPrompt.Value
	terraformMetalPlatform.SSHUser = sshUserPrompt.Value

	if platformHasGPU {
		if terraformMetalPlatform.SetupNvidia {
			if err := rebootGPUNodesPrompt.Run(); err != nil {
				return err
			}

			terraformMetalPlatform.RebootGPUNodes = cli.YesNoToBool(rebootGPUNodesPrompt.Value)
		}
	}

	return nil
}

func saveFilePath(path, destPath string) error {
	_, err := os.Stat(path)
	if err != nil {
		return err
	}

	srcFile, err := os.Open(path)
	if err != nil {
		return err
	}
	defer srcFile.Close()

	if err := os.MkdirAll(filepath.Dir(destPath), 0700); err != nil {
		return nil
	}

	destFile, err := os.Create(destPath)
	if err != nil {
		return err
	}
	defer destFile.Close()

	n, err := io.Copy(destFile, srcFile)
	if err != nil {
		return err
	}

	if n == 0 {
		return fmt.Errorf("Source file is empty: %s", path)
	}

	return nil
}

func setupSSL(terraformCommon *terraform.Common, terraformDir string) error {
	var method string

	if terraformCommon.HasValidTLS() {
		method = "cert"
	}
	if terraformCommon.HasValidLetsEncrypt() {
		method = "letsencrypt"
	}

	sslSetupSelect := promptui.Select{
		Label: "SSL Setup Method",
		Items: []string{"cert", "letsencrypt"},
	}

	println("")
	println(cli.TextHeader("Setup SSL"))

	_, method, err := sslSetupSelect.Run()
	if err != nil {
		return err
	}

	switch method {
	case "cert":
		terraformCommon.LetsEncryptDNSName = ""
		terraformCommon.LetsEncryptDNSSettings = make(map[string]string)

		tlsCertPrompt := cli.Prompt{
			Label:    "SSL Certificate Path",
			Required: true,
			Value:    terraformCommon.GetTLSCert(),
		}
		tlsKeyPrompt := cli.Prompt{
			Label:    "SSL Key Path",
			Required: true,
			Value:    terraformCommon.GetTLSKey(),
		}

		println("")
		println(cli.TextHeader("Setup SSL Certificates"))

		for {
			if err := tlsCertPrompt.Run(); err != nil {
				return err
			}

			storedTLSCert := filepath.Join(terraformDir, "ssl.cert")
			if tlsCertPrompt.Value != storedTLSCert {
				if err := saveFilePath(tlsCertPrompt.Value, storedTLSCert); err != nil {
					println("Could not save file to cluster directory, please try again")
					continue
				}
			}

			terraformCommon.SetTLSCert(storedTLSCert)
			break
		}

		for {
			if err := tlsKeyPrompt.Run(); err != nil {
				return err
			}

			storedTLSKey := filepath.Join(terraformDir, "ssl.key")
			if tlsKeyPrompt.Value != storedTLSKey {
				if err := saveFilePath(tlsKeyPrompt.Value, storedTLSKey); err != nil {
					println("Could not save file to cluster directory, please try again")
					continue
				}
			}

			terraformCommon.SetTLSKey(storedTLSKey)
			break
		}

	case "letsencrypt":
		terraformCommon.TLSCert = ""
		terraformCommon.TLSKey = ""

		letsEncryptDNSProviderPrompt := cli.Prompt{
			Label:    "DNS Provider Name",
			Required: true,
			Value:    terraformCommon.LetsEncryptDNSName,
		}

		letsEncryptDNSSettings := ""
		if len(terraformCommon.LetsEncryptDNSSettings) > 0 {
			letsEncryptDNSSettingsBytes, err := json.Marshal(terraformCommon.LetsEncryptDNSSettings)
			if err != nil {
				letsEncryptDNSSettings = ""
			} else {
				letsEncryptDNSSettings = string(letsEncryptDNSSettingsBytes)
			}
		}

		letsEncryptDNSSettingsPrompt := cli.Prompt{
			Label:    "JSON DNS Environment Variables",
			Required: true,
			Value:    string(letsEncryptDNSSettings),
		}

		println("")
		println(cli.TextHeader("Setup Let's Encrypt (see https://docs.traefik.io/v1.7/configuration/acme)"))

		if err := letsEncryptDNSProviderPrompt.Run(); err != nil {
			return err
		}

		for {
			if err := letsEncryptDNSSettingsPrompt.Run(); err != nil {
				return err
			}

			terraformCommon.LetsEncryptDNSName = letsEncryptDNSProviderPrompt.Value

			if err := json.Unmarshal([]byte(letsEncryptDNSSettingsPrompt.Value), &terraformCommon.LetsEncryptDNSSettings); err != nil {
				println("Invalid JSON, please try again")
				letsEncryptDNSSettingsPrompt.Value = ""
				continue
			}
			break
		}
	}

	return nil
}

func setupTerraformProvider(terraformProvider *terraform.TerraformProvider) error {
	useSystemS3Credentials := true

	println(cli.TextHeader("Configure an S3 bucket to store Terraform state"))
	s3AccessKeyIDPrompt := cli.Prompt{
		Label:          "Access Key ID",
		MaskShowLength: 4,
		Required:       true,
		UseMask:        true,
		Value:          terraformProvider.Backends.S3.AccessKeyID,
	}
	s3BucketPrompt := cli.Prompt{
		Label:    "Bucket",
		Required: true,
		Value:    terraformProvider.Backends.S3.Bucket,
	}
	s3KeyPrompt := cli.Prompt{
		Label:    "Key Path (secrets will be stored here)",
		Required: true,
		Value:    terraformProvider.Backends.S3.Key,
	}
	s3SecretAccessKeyPrompt := cli.Prompt{
		Label:          "Secret Access Key",
		MaskShowLength: 4,
		Required:       true,
		Value:          terraformProvider.Backends.S3.SecretAccessKey,
		UseMask:        true,
	}
	s3RegionPrompt := cli.Prompt{
		Label: "Region",
		Value: terraformProvider.Backends.S3.Region,
	}
	s3EndpointPrompt := cli.Prompt{
		Label: "Endpoint",
		Value: terraformProvider.Backends.S3.Endpoint,
	}
	useSystemS3CredentialsPrompt := cli.Prompt{
		Label:         "Use system S3 credentials (~/.aws or environment variables)?",
		Required:      true,
		AllowedValues: cli.YesNoValues,
		Value:         cli.BoolToYesNo(useSystemS3Credentials),
	}

	if err := s3BucketPrompt.Run(); err != nil {
		return err
	}
	if err := s3KeyPrompt.Run(); err != nil {
		return err
	}
	if err := s3RegionPrompt.Run(); err != nil {
		return err
	}
	if err := s3EndpointPrompt.Run(); err != nil {
		return err
	}
	if err := useSystemS3CredentialsPrompt.Run(); err != nil {
		return err
	}

	if !cli.YesNoToBool(useSystemS3CredentialsPrompt.Value) {
		if err := s3AccessKeyIDPrompt.Run(); err != nil {
			return err
		}
		if err := s3SecretAccessKeyPrompt.Run(); err != nil {
			return err
		}

		terraformProvider.Backends.S3.AccessKeyID = s3AccessKeyIDPrompt.Value
		terraformProvider.Backends.S3.SecretAccessKey = s3SecretAccessKeyPrompt.Value
	} else {
		terraformProvider.Backends.S3.AccessKeyID = ""
		terraformProvider.Backends.S3.SecretAccessKey = ""
	}

	terraformProvider.Backends.S3.Bucket = s3BucketPrompt.Value
	terraformProvider.Backends.S3.Endpoint = s3EndpointPrompt.Value
	terraformProvider.Backends.S3.Key = s3KeyPrompt.Value
	terraformProvider.Backends.S3.Region = s3RegionPrompt.Value

	if s3RegionPrompt.Value == "none" || s3RegionPrompt.Value == "main" || s3RegionPrompt.Value == "minio" ||
		s3RegionPrompt.Value == "" {
		terraformProvider.Backends.S3.Region = "main"
		terraformProvider.Backends.S3.SkipRegionValidation = true
		terraformProvider.Backends.S3.SkipCredentialsValidation = true
		terraformProvider.Backends.S3.SkipMetadataAPICheck = true
		terraformProvider.Backends.S3.ForcePathStyle = true
	}

	return nil
}

func NewClusterUpCommand() *cobra.Command {
	var autoApprove bool
	var reinstall bool

	command := cobra.Command{
		Use:   "up [CLUSTER_ID]",
		Args:  cobra.MaximumNArgs(1),
		Short: "Setup cluster",
		RunE: func(cmd *cobra.Command, args []string) error {
			var id string

			// Prepare args
			client := cli.FromContext(cmd)
			if len(args) > 0 {
				id = args[0]
			} else {
				var err error
				id, err = ClusterRegister(client, "")
				if err != nil {
					return err
				}
			}
			terraformDir := filepath.Join("clusters", id)

			// Check if cluster is valid
			checkCluster, err := client.GetCluster(id, paperspace.ClusterGetParams{})
			if err != nil {
				return err
			}
			if !terraform.IsSupportedPlatform(checkCluster.Platform) {
				return fmt.Errorf("Platform '%s' is not currently supported by %s", checkCluster.Platform, cli.Name)
			}

			// Update cluster to regenerate cluster API key and cluster secret
			updateClusterParams := paperspace.ClusterUpdateParams{
				ID:                     id,
				CreateNewToken:         true,
				CreateNewClusterSecret: true,
			}
			cluster, err := client.UpdateCluster(id, updateClusterParams)
			if err != nil {
				return err
			}
			terraformInstance := terraform.NewTerraform(cluster.Platform)

			// Load existing config values if exists
			if err := config.LoadConfigIfExists(terraformDir, TerraformTFName, terraformInstance); err != nil {
				return err
			}

			// Check if terraform Provider values are valid
			if terraformInstance.TerraformProvider.Backends.S3.Key == "" {
				terraformInstance.TerraformProvider.Backends.S3.Key = fmt.Sprintf("cluster/%s.tfstate", id)
			}

			if reinstall || !terraformInstance.HasValidTerraformProvider() {
				if err = setupTerraformProvider(terraformInstance.TerraformProvider); err != nil {
					return err
				}
			}

			// Update cluster API values
			terraformCommon := terraformInstance.GetCommon(cluster.Platform)
			terraformCommon.UpdateFromCluster(&cluster)

			// Check SSL settings are valid
			if reinstall || !terraformCommon.HasValidSSL() {
				configDir, err := config.ConfigDirectory()
				if err != nil {
					return err
				}

				sslDir := filepath.Join(configDir, terraformDir)
				if err := setupSSL(terraformCommon, sslDir); err != nil {
					return err
				}
			}

			// Specific
			switch cluster.Platform {
			case paperspace.ClusterPlatformAWS:
			case paperspace.ClusterPlatformMetal,
				paperspace.ClusterPlatformDGX,
				paperspace.ClusterPlatformGraphcore,
				paperspace.ClusterPlatformSambaNova:
				if reinstall || !terraformInstance.HasValidMetal() {
					if err := setupMetalConfig(terraformInstance.Modules.Metal, cluster.Platform); err != nil {
						return err
					}
				}
			}

			// Check for source prefix override
			sourcePrefix := os.Getenv("PAPERSPACE_TERRAFORM_PREFIX")
			if sourcePrefix != "" {
				terraformCommon.UpdateSourcePrefix(sourcePrefix, cluster.Platform)
			}

			// Write Config
			if err := config.WriteConfig(terraformDir, TerraformTFName, terraformInstance); err != nil {
				return err
			}

			// Terraform apply
			configPath, err := config.ConfigPath(terraformDir, TerraformTFName)
			if err != nil {
				return err
			}

			println("")
			println(cli.TextHeader("Running terraform"))
			if err := terraform.InitCommand(filepath.Dir(configPath)); err != nil {
				return err
			}
			if err := terraform.ApplyCommand(filepath.Dir(configPath), autoApprove); err != nil {
				return err
			}

			kubeconfigPath := filepath.Join(filepath.Dir(configPath), "cluster-kubeconfig")
			println(cli.TextSuccess(fmt.Sprintf("KUBECONFIG path: %s", kubeconfigPath)))
			println(cli.TextSuccess(fmt.Sprintf("Cluster %s is up!", cluster.Name)))

			return nil
		},
	}
	command.PersistentFlags().BoolVarP(&reinstall, "reinstall", "r", false, "")
	command.PersistentFlags().BoolVarP(&autoApprove, "auto-approve", "a", false, "")

	return &command
}
