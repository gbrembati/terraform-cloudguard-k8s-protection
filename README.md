# CloudGuard Kubernetes Protection
This Terraform project creates a Kubernetes environment in Azure (AKS) and protects it with Check Point technologies. In this case, we use four different Terraform providers: [Azure](https://registry.terraform.io/providers/hashicorp/azurerm/latest), [Kubernetes](https://registry.terraform.io/providers/hashicorp/kubernetes/latest), [Helm](https://registry.terraform.io/providers/hashicorp/helm/latest), [CloudGuard](https://registry.terraform.io/providers/dome9/dome9/latest).     
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
7. **Helm: Cloudguard CSPM components**: it creates all the CPSM components needed in AKS using a Helm Chart
8. **Helm: Cloudguard AppSec components**: it creates all the Appsec components needed in the cluster using a Helm Chart

## How to start?
First, you need to have a CloudGuard CSPM account, and if you don't, you can create one with these links:
1. Create an account in [Europe Region](https://secure.eu1.dome9.com/v2/register/invite)
2. Create an account in [Asia Pacific Region](https://secure.ap1.dome9.com/v2/register/invite)
3. Create an account in [United States Region](https://secure.dome9.com/v2/register/invite)

## Get API credentials in your CloudGuard CPSM Portal
Then you will need to get the API credentials that you will be using with Terraform to onboard the accounts.

![CSPM Service Account](/zimages/create-cpsm-serviceaccount.jpg)

Remember to copy these two values! You will need to enter them in the *.tfvars* file later on.

## Get Appsec token in your Check Point Infinity Portal
You will need to use them for the Infinity Portal configuration, in the INFINITY POLICY application.    
If you don't have a Portal you can create one following this link: [Register](https://portal.checkpoint.com/create-account)

Under the Infinity Policy Tab go to "Getting Started" > "Assets" > "New Asset" > "Web Application"
Then follow this configuration steps:
![Appsec WebApp Configuration](/zimages/create-appsec-application.jpg)

On the profile page copy then the token! You will need to enter them in the *.tfvars* file later on.
![Appsec Token](/zimages/get-appsec-token.jpg)

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

# CSPM API endpoint: - for US use: 'https://api.dome9.com/v2/'
#                    - for EU use: 'https://api.eu1.dome9.com/v2/'
cspm-api-endpoint = "https://api.dome9.com/v2/"
# Where is your CSPM platform instanced? usea1 [default], euwe1, apso1
cspm-residency  = "usea1"

appsec-token    = "cp-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```
If you want (or need) to further customize other project details, you can change defaults in the different __*name-variables.tf*__ files.
Here you will also be able to find the descriptions that explain what each variable is used for.

## Launch terraform to build the infrastructure
##
To prepare the current working directory (and install the required providers) run :
```hcl
terraform init 
```
##
To create an execution plan (and see the changes that will be made in your environment) run :
```hcl
terraform plan
``` 
##
To apply the changes required to reach the desired state (and create your environment) run :
```hcl
terraform apply
```
## 
## Create the A record in the Azure DNS zone
Once the terraform project will be applied correctly, you will have the application running an protected and you will need to create A record in the Azure DNS zone to use to reach the application with the ingress public IP. Please make sure to provide the same name then you did in the Appsec WebApp configuration.