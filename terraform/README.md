#   Deployment instructions



## XC Cloud credentials

Sign in to the F5 Distributed Cloud Console and open the **Administration** tab.

![](../assets/terraform/administration.png)

Open the **Credentials** section and click **Add Credentials**.

![](../assets/terraform/create_credentials.png)

Fill the form as on the screen below and download your credentials file.

![](../assets/terraform/fill_credentials.png)

Move the credentials file to the **terraform** directory and rename it to **api-creds.p12**. Inside each module, there is a **var.tf** file where you can adjust the path to the credentials file. By default, all modules use the same file from the **terraform** folder.

    variable "xc_api_p12_file" {
      default = "./path-to-api-cert.p12"
    }

Create **VES_P12_PASSWORD** environment variable with the password from the previous step.

    export VES_P12_PASSWORD=your_certificate_password

## Azure App Stack Branch

Before running the Terraform script, please ensure that you have [installed the Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) and have [signed in to your Azure Account](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli). It is required that you have the **Owner** role and create service principal subscription with **Contributor** role for it. You also must [accept the subscription agreement](https://docs.cloud.f5.com/docs/how-to/site-management/create-azure-site#accept-subscription-agreement) to deploy the XC Azure VNET Site.


Open the **./azure-app-stack-branch/var.tf** file and fill in the variables with your Azure Tenant ID and Subscription ID:

    variable "azure_subscription_id" {
        type = string
        default = "your_subscription_id"
    }

    variable "azure_subscription_tenant_id" {
        type = string
        default = "your_tenant_id"
    }

Find **xc_api_url** variable and fill it with your F5 xC tenant name.

    variable "xc_api_url" {
        type = string
        default = "https://your_tenant.console.ves.volterra.io/api"
    }

Update **azure_rg_location** if you want to use another Azure region

    variable "azure_rg_location" {
      type    = string
      default = "eastus2"
    }

Navigate to the **azure-app-stack-branch** folder and initialize Terraform by running init command.

    cd ./azure-app-stack-branch
    terraform init

Apply Terraform script.

    terraform apply

Save the output

    terraform output

    application_id = "xxxxxxxxx"
    appstack_private_ip = "10.125.10.5"
    azure_vnet_name = "branch-a-network"
    kiosk_address = "198.51.100.20"
    kiosk_password = <sensitive>
    kiosk_user = "azureuser"
    service_principal_password = <sensitive>
    subnet_a_name = "subnet_a"
    subscription_id = "xxxxxxxxx"
    tenant = "xxxxxxxxx"
    xc_private_key = <sensitive>
    xc_public_key = ssh-rsa AAAAB3NzaC....
    
Connect to the kiosk VM with RDP connection and update DNS Server. Use **kiosk_address** from the output. **azureuser** as a login. To retrieve the password following command:

    terraform output kiosk_password

Open DNS settings and use the DNS server from the output **appstack_private_ip** and any public as a Secondary DNS

    10.125.10.5
    8.8.8.8

See [Test Kiosk](https://github.com/f5devcentral/xcedgedemoguide#test-kiosk) for more information.

## AWS CE Site

Create stack using the cloud formation template for AWS Cloud Credentials.

Sign into your AWS Account and type CloudFormation in the search bar. Then open the CloudFormation service.

![](../assets/terraform/aws_homepage.png)

Click Create stack.

![](../assets/terraform/aws_create_stack.png)

Upload cloudformation template located in the **./cloudformation/aws-service-account.yaml** and click **Next**.

![](../assets/terraform/aws_stack_upload.png)

Fill required parameters and click Next.

* **Stack name** - The name associated with the AWS Cloud Formation stack. For example: xc-cloud-access
* **Policy Name** - The name of the Service Account Policy. For example: F5XCServiceAccountPolicyForAWSSite

![](../assets/terraform/aws_stack_details.png)

Click **Next**.

![](../assets/terraform/aws_stack_next_1.png)

Check **acknowledge** checkbox and click **Create stack**.

![](../assets/terraform/aws_stack_next_2.png)

In a few minutes navigate to the **Output** tab and find your **Access Key** and **Access Secret**. Note down those keys.

![](../assets/terraform/aws_keys.png)

The Access Key and the Secret Key can be used to create the AWS Programmatic Access Credentials on F5® Distributed Cloud Console. See [AWS Cloud Credentials](https://docs.cloud.f5.com/docs/how-to/site-management/cloud-credentials#aws-programmable-access-credentials) for more information.

Open **./aws-ce-site/var.tf** and fill variables with your AWS Access Key and Access Secret.

    variable "aws_access_key" {
      type = string
      default = "your_aws_access_key"
    }

    variable "aws_secret_key" {
      type = string
      default = "your_aws_access_secret"
    }

Update **aws_region** if you want to use another AWS region

    variable "aws_region" {
      type    = string
      default = "us-east-2"
    }

Find **xc_api_url** variable and fill it with your F5 xC tenant name.

    variable "xc_api_url" {
      type = string
      default = "https://your_tenant.console.ves.volterra.io/api"
    }

Update path to the XC p12 certificate file.

    variable "xc_api_p12_file" {
      default = "./path-to-api-cert.p12"
    }

Navigate to the **aws-ce-site** folder and initialize Terraform by running init command.

    cd ./aws-ce-site
    terraform init

Apply Terraform script.

    terraform apply


## Module 1

Generate mk8s config file as [described in the guide](https://github.com/f5devcentral/xcedgedemoguide#get-mk8s-kubeconfig).

Open **./module_1/var.tf** and update path to the **mk8s config** file.

    variable "kubeconfig_path" {
      type    = string
      default = "../kubeconfig_mk8s.yaml"
    }

Find **xc_api_url** variable and fill it with your F5 xC tenant name.

    variable "xc_api_url" {
      type = string
      default = "https://your_tenant.console.ves.volterra.io/api"
    }

Navigate to the **module_1** folder and initialize Terraform by running init command.

    cd ./module_1
    terraform init

Apply Terraform script.

    terraform apply

## Module 2

Open **./module_2/var.tf** and update **user_domain** variable with your domain name

    variable "user_domain" {
      type    = string
      default = "your_domain_name.example.com"
    }

Find **xc_api_url** variable and fill it with your F5 xC tenant name.

    variable "xc_api_url" {
      type = string
      default = "https://your_tenant.console.ves.volterra.io/api"
    }

Navigate to the **module_2** folder and initialize Terraform by running init command.

    cd ./module_2
    terraform init

Apply Terraform script.

    terraform apply

## Module 3

Open **./module_3/var.tf** and update **user_domain** variable with your domain name

    variable "user_domain" {
      type    = string
      default = "your_domain_name.example.com"
    }

Find **xc_api_url** variable and fill it with your F5 xC tenant name.

    variable "xc_api_url" {
      type = string
      default = "https://your_tenant.console.ves.volterra.io/api"
    }

Navigate to the **module_3** folder and initialize Terraform by running init command.

    cd ./module_3
    terraform init

Apply Terraform script.

    terraform apply


## Clean up

Run the **terraform destroy** command in each folder.

    terraform destroy
