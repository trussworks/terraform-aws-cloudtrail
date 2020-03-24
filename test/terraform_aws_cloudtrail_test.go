package test

import (
	"fmt"
	"strings"
	"testing"

	awssdk "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/cloudtrail"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

const awsRegion = "us-west-2"

func NewCloudTrailClientE(t *testing.T, region string) (*cloudtrail.CloudTrail, error) {
	sess, err := aws.NewAuthenticatedSession(region)
	if err != nil {
		return nil, err
	}
	return cloudtrail.New(sess), nil
}

func IsLogging(t *testing.T, region string, trailName string) (bool, error) {
	cloudTrailClient, err := NewCloudTrailClientE(t, region)
	if err != nil {
		return false, err
	}
	params := &cloudtrail.GetTrailStatusInput{
		Name: awssdk.String(trailName),
	}

	trailStatus, err := cloudTrailClient.GetTrailStatus(params)
	if err != nil {
		return false, err
	}
	return *trailStatus.IsLogging, nil
}

func TestTerraformAwsCloudtrail(t *testing.T) {
	t.Parallel()

	testName := fmt.Sprintf("terratest-aws-cloudtrail-%s", strings.ToLower(random.UniqueId()))
	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/simple")

	terraformOptions := &terraform.Options{
		TerraformDir: tempTestFolder,
		Vars: map[string]interface{}{
			"trail_name":                testName,
			"cloudwatch_log_group_name": testName,
			"logs_bucket":               testName,
			"region":                    awsRegion,
			"s3_key_prefix":             "testName",
			"encrypt_cloudtrail":        false,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	cloudtrailArn := terraform.Output(t, terraformOptions, "cloudtrail_arn")
	isLogging, err := IsLogging(t, awsRegion, cloudtrailArn)
	assert.NoError(t, err)
	assert.True(t, isLogging)

}

func TestTerraformAwsCloudtrailEncryption(t *testing.T) {
	t.Parallel()

	testName := fmt.Sprintf("terratest-aws-cloudtrail-%s", strings.ToLower(random.UniqueId()))
	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/simple")

	terraformOptions := &terraform.Options{
		TerraformDir: tempTestFolder,
		Vars: map[string]interface{}{
			"trail_name":                testName,
			"cloudwatch_log_group_name": testName,
			"logs_bucket":               testName,
			"region":                    awsRegion,
			"s3_key_prefix":             "testName",
			"encrypt_cloudtrail":        true,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	cloudtrailArn := terraform.Output(t, terraformOptions, "cloudtrail_arn")
	isLogging, err := IsLogging(t, awsRegion, cloudtrailArn)
	assert.NoError(t, err)
	assert.True(t, isLogging)
}
