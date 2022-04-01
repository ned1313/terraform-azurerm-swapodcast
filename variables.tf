# Variables that we will need

# Azure region
variable "region" {
  
}

# Common tags
variable "common_tags" {
  
}

# SWA Tier (default to Free)
variable "static_web_app_sku" {
  default = "Free"
}

# Name of podcast
variable "podcast_name" {
  
}

# Custom domain if desired
variable "custom_domain" {
  default = null
}

# Custom name for domain
variable "custom_domain_name" {
  
}

# TXT or CNAME validation
variable "custom_domain_validation" {
  
}

# Azure DNS info, if using custom domain hosted on Azure
variable "azure_dns_resource_group" {
  
}

# GitHub repository address
variable "github_repository" {
  
}

# Azure CDN enabled?
variable "azure_cdn_enabled" {
  
}

variable "azure_cdn_sku" {
  default = "Standard_Microsoft"
}

# Azure CDN locations (defaults to NA)
variable "azure_cdn_locations" {
  
}

