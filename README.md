# CloudGuard Kubernetes Protection
This Terraform project is intended to create a Kubernetes environment in Azure (AKS) and protects it with Check Point technologies: CSPM, Workload and AppSec.     
In this case, we use four different Terraform providers: [Azure](https://registry.terraform.io/providers/hashicorp/azurerm/latest), [Kubernetes](https://registry.terraform.io/providers/hashicorp/kubernetes/latest), [Helm](https://registry.terraform.io/providers/hashicorp/helm/latest), [CloudGuard](https://registry.terraform.io/providers/dome9/dome9/latest).     
As per my deployments (made in France Central), this project creates all of the following in less than __10 minutes__.    

## Which are the components created?
The project creates the following resources and combines them:
1. **Azure: AKS Cluster**: it connects to Azure and create a managed instance of Kubernetes (AKS) with its nodepool
2. **Azure: DNS Zone**: it creates a dns zone in Azure which will then be used to publish the application FQDN
3. **K8s: Juice Shop Deployment**: it deploys a Juice Shop application on the Kubernetes Cluster 
4. **Cloudguard CSPM: Cluster Onboarding**: it creates the K8s environment in the CloudGuard Portal for CSPM and Worklaod 
5. **Cloudguard CSPM: Notification**: it creates a notification to send the findings via mail
6. **Cloudguard CSPM: Continuous Compliance Policy**: it creates a continuous policy with the Kubernetes Best Practice Ruleset
7. **Helm: Cloudguard CSPM components**: it creates all the CPSM components needed in AKS using a Helm Chart
8. **Helm: Cloudguard AppSec components**: it creates all the Appsec components needed in the cluster using a Helm Chart

## How to start?
First, you need to have a CloudGuard CSPM account, and if you don't, you can create one with these links:
1. Create an account in [Europe Region](https://secure.eu1.dome9.com/v2/register/invite)
2. Create an account in [Asia Pacific Region](https://secure.ap1.dome9.com/v2/register/invite)
3. Create an account in [United States Region](https://secure.dome9.com/v2/register/invite)

## Get API credentials in your CPSM Portal
Then you will need to get the API credentials that you will be using with Terraform to onboard the accounts.

![CSPM Service Account](/zimages/create-cpsm-serviceaccount.jpg)

Remember to copy these two values! You will need to enter them in the *.tfvars* file later on.

## How to use it
The only thing that you need to do is changing the __*terraform.tfvars*__ file located in this directory.

```hcl
# Set in this file your deployment variables
azure-client-id     = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
azure-client-secret = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
azure-tenant        = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
azure-subscription  = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

location                = "France Central"
log-analytics-location  = "francecentral"
mydns-zone              = "<yourzone>.com"

cspm-mail       = "<youremail>@<yourdomain>.com"
cspm-key-id     = "xxxxxxxxxxxxxx"
cspm-key-secret = "xxxxxxxxxxxxxx"
cspm-org-unit   = "xxxxxxxxxxxxxx"

# Where is your CSPM platform instanced? usea1 [default], euwe1, apso1
cspm-residency  = "usea1"
# Specify the CSPM API endpoint for US use: 'https://api.dome9.com/v2/' for EU use: 'https://api.eu1.dome9.com/v2/'
cspm-api-endpoint = "https://api.dome9.com/v2/"

appsec-token    = "cp-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```
If you want (or need) to further customize other project details, you can change defaults in the different __*name-variables.tf*__ files.
Here you will also be able to find the descriptions that explain what each variable is used for.