terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.102.0"
    }
  }
}

provider "azurerm" {
  features {}
  client_id =  "f3b9490a-be1a-4ddb-8525-a75c1215d100"
  client_secret = "w2B8Q~BzT6cVi2zzs27EqdvLVWqUWdqvHChEmbeB" 
  tenant_id =  "c191ade4-ed17-4b97-b9e6-c2817e56c2b1"
  subscription_id = "eafd9295-b3a8-4de9-99df-aca03724e5da"
}