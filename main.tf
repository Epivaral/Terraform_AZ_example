terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.69.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
}

resource "azurerm_resource_group" "MyRG" {
  name     = "RG_TF_Tests"
  location = "East US"
  tags = {
    environment = "Modification tests"
  }
}

#Azure SQL server
resource "azurerm_mssql_server" "sqlserver" {
  name                = "eduardopivaral-tf"
  resource_group_name = azurerm_resource_group.MyRG.name
  location            = azurerm_resource_group.MyRG.location
  version             = "12.0"
  # note that the user and password is plain text, for this case we use variables, 
  # but that is out of scope for this tip, we will discuss this on next tips.
  administrator_login          = "Gato"
  administrator_login_password = "-n0meAcuerd0-"

  #we add our account as administrator of the instance
  azuread_administrator {
    login_username = "<login>@<domain>.com"
    object_id      = "d80sF5a9e9-1e09-4e25-b383-123a132c847d"
  }
}


# Azure SQL Database
resource "azurerm_mssql_database" "sqldb" {
  name                 = "demoData"
  server_id            = azurerm_mssql_server.sqlserver.id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  sku_name             = "Basic" #we use basic tier
  storage_account_type = "Local" #local redundancy storage
  tags = {
    description = "Part 1 - just the empty resource"
  }
}


#firewall rule to allow us access to it
resource "azurerm_mssql_firewall_rule" "MyLaptopRule" {
  name             = "MyLaptopRule"
  server_id        = azurerm_mssql_server.sqlserver.id
  start_ip_address = "186.309.150.258" #this IP does not exists, put yours!
  end_ip_address   = "186.309.150.258"
}
