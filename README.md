### Terraform Infrastructure Deployment
This Terraform project demonstrates how to deploy an infrastructure that consists of a VPC, subnets, Auto Scaling Group (ASG), MySQL RDS, and an NGINX web server. The infrastructure is designed to support two environments, namely production (PRD) and development (DEV). Each environment is differentiated using separate .tfvars files: prd.tfvars and dev.tfvars. Additionally, separate Terraform workspaces are used to manage the environments.

**Prerequisites**
Before you begin, ensure you have the following:

Terraform installed on your local machine.
AWS CLI installed and configured with your AWS credentials.
Access to the target AWS account and necessary permissions to create the required resources.
Project Structure
The project has the following directory structure:

```hcl
terraform-project/
├── main.tf
|── output.tf
├── variables.tf
├── prd.tfvars
├── dev.tfvars
├── userdata.sh
└── README.md
```
main.tf: Contains the main Terraform configuration code that defines the infrastructure resources.
variables.tf: Defines the input variables used in the Terraform configuration.
prd.tfvars: Contains the variable values specific to the production environment.
dev.tfvars: Contains the variable values specific to the development environment.
userdata.sh: Contains the user data script used for automated NGINX deployment.
README.md: This file, providing an overview of the project and instructions for usage.
Usage
Follow these steps to deploy the infrastructure:

Clone this repository to your local machine:


git clone <repository_url>
Navigate to the project directory:


cd terraform-project
Initialize the Terraform working directory:

```hcl
terraform init
Select the workspace for the environment you want to deploy:
```

```hcl
terraform workspace select <environment>
Replace <environment> with either prd for production or dev for development.
```
Review the variables.tf file to see the available variables and their descriptions. Adjust any values as needed.

Deploy the infrastructure by running the following command:

```hcl
terraform apply -var-file=<environment>.tfvars
Replace <environment> with either prd or dev, depending on the workspace selected.
```
This command will prompt you to confirm the infrastructure deployment. Enter yes to proceed.

Terraform will provision the infrastructure according to the specified configuration. Monitor the output for any errors or status updates.

Once the deployment is complete, Terraform will display the outputs, including the necessary information to access the deployed resources.

Clean Up
To clean up and destroy the infrastructure created by Terraform, you can run the following command:

```hcl
terraform destroy -var-file=<environment>.tfvars
Replace <environment> with either prd or dev, depending on the workspace selected.
```
Review the changes that will be made, and if everything looks correct, enter yes to proceed. Terraform will remove all resources associated with the configuration.

Remember that destroying the infrastructure is a potentially irreversible action, so exercise caution when using this command.

Conclusion
This README file provides an overview of the Terraform project and instructions for deploying and managing the infrastructure for the PRD and DEV environments. Make sure to review the code and customize it according to your specific needs before running any Terraform commands.

Always exercise caution when working with infrastructure provisioning and follow best practices for security and resource management.