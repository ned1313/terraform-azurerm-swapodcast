# Resources to deploy

# Random ID to prevent collisions
resource "random_integer" "swa" {
  min = 1000
  max = 9999
}

locals {
  basename = "${var.podcast_name}-${random_integer.swa.result}"
  storage_account_name = lower(local.basename)
}

# Azure resource group

resource "azurerm_resource_group" "swa" {
  name     = local.basename
  location = var.region
  tags = var.common_tags
}

# Azure static web app

resource "azurerm_static_site" "swa" {
  name                = local.basename
  resource_group_name = azurerm_resource_group.swa.name
  location            = azurerm_resource_group.swa.location
  sku_tier = var.static_web_app_sku
  tags = var.common_tags
}

resource "azurerm_static_site_custom_domain" "swa" {
  count = (var.custom_domain_validation == "CNAME") ? 1 : 0
  static_site_id  = azurerm_static_site.swa.id
  domain_name     = "${azurerm_dns_cname_record.swa.name}.${azurerm_dns_cname_record.swa.zone_name}"
  validation_type = "cname-delegation"
}

resource "azurerm_static_site_custom_domain" "swa" {
  count = (var.custom_domain_validation == "TXT") ? 1 : 0
  static_site_id  = azurerm_static_site.swa.id
  domain_name     = "${var.custom_domain_name}.${azurerm_dns_cname_record.swa.zone_name}"
  validation_type = "dns-txt-token"
}

# Azure storage account

resource "azurerm_storage_account" "swa" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.swa.name
  location                 = azurerm_resource_group.swa.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  tags = var.common_tags
}

# Azure storage account container with public read enabled

resource "azurerm_storage_container" "swa" {
  name                  = "episodes"
  storage_account_name  = azurerm_storage_account.swa.name
  container_access_type = "blob"
}

# Azure log analytics workbook

resource "azurerm_log_analytics_workspace" "swa" {
  name                = local.basename
  location            = azurerm_resource_group.swa.location
  resource_group_name = azurerm_resource_group.swa.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags = var.common_tags
}

resource "azurerm_monitor_diagnostic_setting" "swa_storage" {
  name = "${local.basename}-storage"
  target_resource_id = azurerm_storage_account.swa.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.swa.id

  metric {
    category = "Transaction"
  }

  log {
    category = "StorageRead"
  }
}

# Azure CDN - optional based on cost

resource "azurerm_cdn_profile" "swa" {
  count = var.azure_cdn_enabled ? 1 : 0
  name                = local.basename
  location            = azurerm_resource_group.swa.location
  resource_group_name = azurerm_resource_group.swa.name
  sku                 = var.azure_cdn_sku
  tags = var.common_tags
}

resource "azurerm_cdn_endpoint" "swa" {
  count = var.azure_cdn_enabled ? 1 : 0
  name                = local.basename
  profile_name        = azurerm_cdn_profile.swa.name
  location            = azurerm_resource_group.swa.location
  resource_group_name = azurerm_resource_group.swa.name

  optimization_type = "GeneralWebDelivery"

  origin {
    name      = local.basename
    host_name = azurerm_storage_account.swa.primary_blob_endpoint
  }
}

# Azure DNS entry - optional if domain is hosted in Azure

resource "azurerm_dns_cname_record" "swa" {
  count = (var.custom_domain_validation == "CNAME") ? 1 : 0
  name                = var.custom_domain_name
  zone_name           = var.custom_domain
  resource_group_name = var.azure_dns_resource_group
  ttl                 = 300
  record              = azurerm_static_site.swa.default_host_name
}

resource "azurerm_dns_txt_record" "swa" {
  count = (var.custom_domain_validation == "TXT") ? 1 : 0
  name                = "_dnsauth.${var.custom_domain_name}"
  zone_name           = var.custom_domain
  resource_group_name = var.azure_dns_resource_group
  ttl                 = 300
  record {
    value = azurerm_static_site_custom_domain.swa.validation_token
  }
}