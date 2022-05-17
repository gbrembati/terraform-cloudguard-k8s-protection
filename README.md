# CloudGuard Kubernetes Protection
This Terraform project creates a Kubernetes environment in Azure (AKS) and protects it with Check Point technologies. In this case, we use five different Terraform providers: [Azure](https://registry.terraform.io/providers/hashicorp/azurerm/latest), [Kubernetes](https://registry.terraform.io/providers/hashicorp/kubernetes/latest), [Helm](https://registry.terraform.io/providers/hashicorp/helm/latest), [CloudGuard](https://registry.terraform.io/providers/dome9/dome9/latest), [Infinity-Next](https://registry.terraform.io/providers/CheckPointSW/infinity-next/1.0.0).     
Once deployed we will have an AKS Cluster with an example application running protected by CloudGuard CSPM, CloudGuard Workload and CloudGuard AppSec.      
As per my deployments (made in France Central), this project creates all of the following in less than __10 minutes__.    

## Which are the components created?
The project creates the following resources and combines them:
1. **Azure: AKS Cluster**: it connects to Azure and create a managed instance of Kubernetes (AKS) with its nodepool
2. **Azure: DNS Zone**: it creates a dns zone in Azure which will then be used to publish the application FQDN
3. **K8s: Juice Shop Deployment**: it deploys a Juice Shop application on the Kubernetes Cluster 
4. **Cloudguard CSPM: Cluster Onboarding**: it creates the K8s environment in the CloudGuard Portal for CSPM and Worklaod 
5. **Cloudguard CSPM: Notification**: it creates a notification to send the findings via mail
6. **Cloudguard CSPM: Continuous Compliance Policy**: it creates a continuous policy with the Kubernetes Best Practice Ruleset
7. **INext: Create Appsec Profile**: in Infinity policy portal creates an Appsec Kubernetes profile
8. **INext: Create Appsec Web Application**: in Infinity policy portal creates the juice shop web app
9. **Helm: Cloudguard CSPM components**: it creates all the CPSM components needed in AKS using a Helm Chart
10. **Helm: Cloudguard AppSec components**: it creates all the Appsec components needed in the cluster using a Helm Chart

## How to start?
First, you need to have a CloudGuard CSPM account, and if you don't, you can create one with these links:
1. Create an account in [Europe Region](https://secure.eu1.dome9.com/v2/register/invite)
2. Create an account in [Asia Pacific Region](https://secure.ap1.dome9.com/v2/register/invite)
3. Create an account in [United States Region](https://secure.dome9.com/v2/register/invite)

## Get API credentials in your CloudGuard CPSM Portal
Then you will need to get the API credentials that you will be using with Terraform to onboard the accounts.

![CSPM Service Account](/zimages/create-cpsm-serviceaccount.jpg)

Remember to copy these two values! You will need to enter them in the *.tfvars* file later on.

## Get Appsec API Credential from Check Point Infinity Portal
You will need to use them for the Infinity Portal configuration, in the INFINITY POLICY application.    
If you don't have a Portal you can create one following this link: [Register](https://portal.checkpoint.com/create-account)

Under the Infinity Policy Tab go to "Setting" (bottom left) > "API Keys" > "New"
The configuration will be done in this section:
![Appsec API Access](/zimages/create-appsec-service-account.jpg)

Once created you will be prompted with the API Key & Secret! You will need to enter them in the *.tfvars* file later on.

## How to use it
In order to use this project you would now need of infinity next Cli Tool and Terraform.     
Here is why: 
*"All changes that are made when running terraform apply are done under a session of the configured API key.*     
*At Infinity Next, each session must be published to be able to enforce your configured policies on your assets. Think of it as commiting your changes to be able to make a release.*      
*Due to Terraform's lack of concept of session management/commiting changes at the end of an applied configuration, it's required from the user of this provider to publish and enforce the applied configuration by himself."*

In order to configure inext plug in, follow the instruction at [CheckPointSW / terraform-provider-infinity-next](https://github.com/CheckPointSW/terraform-provider-infinity-next) on how to set the credentials and download the tool.

##
Now you would need to change the __*terraform.tfvars*__ file located in this directory.

```hcl
# Set in this file your deployment variables
azure-client-id         = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
azure-client-secret     = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
azure-tenant            = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
azure-subscription      = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

location                = "France Central"
log-analytics-location  = "francecentral"
mydns-zone              = "<yourzone>.com"

cspm-mail               = "<youremail>@<yourdomain>.com"
cspm-key-id             = "xxxxxxxxxxxxxx"
cspm-key-secret         = "xxxxxxxxxxxxxx"
cspm-org-unit           = "xxxxxxxxxxxxxx"

# CSPM API endpoint: - for US use: 'https://api.dome9.com/v2/'
#                    - for EU use: 'https://api.eu1.dome9.com/v2/'
cspm-api-endpoint       = "https://api.dome9.com/v2/"
# Where is your CSPM platform instanced? usea1 [default], euwe1, apso1
cspm-residency          = "usea1"

appsec-client-id        = "xxxxxxxxxxxxxx"
appsec-client-secret    = "xxxxxxxxxxxxxx"
```
If you want (or need) to further customize other project details, you can change defaults in the different __*name-variables.tf*__ files.
Here you will also be able to find the descriptions that explain what each variable is used for.

## Launch terraform to build the infrastructure
To prepare the current working directory (and install the required providers) run :
```hcl
terraform init 
```
##
To apply the changes required to reach the desired state (and create your environment) run :
```hcl
terraform apply
inext publish && inext enforce
```

## Terraform Project Outputs
Once the  project will be applied correctly, you will receive two output with the FQDN to connect to the application.     
The first is the one where the application lives behind appsec, the second one is the directly exposed application.     
```hcl
Outputs:
juiceshop-protected-fqdn = "http://juiceshop-protected.<yourzone>.com"
juiceshop-unprotected-fqdn = "http://juiceshop-unprotected.<yourzone>.com"
```