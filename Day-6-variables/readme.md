Terrafom variables
1. input variables
1. inline variables
    ( variable passing method: 1. using default values in variables 2. runtime variables)
    Example : inside main.tf
    # Inline variables
        variable "rg" {
            type = string
            default = "Terraform-RG" # very least way to pass variable value
            description = "This variable for RG Creation"
        }
2. external variables 
    ( variable passing method: 1. using default values in variables 2. runtime variables)
    Example : create variales.tf separate file in working directory
    working directory
            |
            ------main.tf
            ------variables.tf

terraform runtime variable example : 
--> terraform plan -var="rg=variable-rg" -var="location=westus"
--> terraform apply -var="rg=variable-rg" -var="location=westus"
======================================================================
variable passing method
1. using default values ( lease  method )
2. run time variables (lease method)
3. using tfvars file ( first priority)
=======================================================================
2. local variables
    inline locals
    Example : inside main.tf
    # Inline variables
        locals {
        resource_group_name = "local-rg"
        location = "eastasia"
    }

2. external variables 
    ( variable passing method: 1. using default values in variables 2. runtime variables)
    Example : create locals.tf separate file in working directory
    working directory
            |
            ------main.tf
            ------locals.tf
3. output variables
    output variables are used to extract and display values from your configuration. They help you expose useful information about your infrastructure, such as resource details, that might be needed after execution. Output variables can also be used to pass data between modules.
    
    Example 
    output "rg-output" {
    value = azurerm_resource_group.name-rg.id
    }
    output "rg-output2" {
     value = azurerm_resource_group.test.location
    }
