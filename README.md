# Azure Static Web App for Podcasts

A Terraform module meant to deploy an Azure Static Web App to host a podcast.

## Description

This module is meant to deploy the necessary components to host an Azure Static Web App (SWA), Azure Storage Account, and Azure CDN to host a podcast. The SWA is the front end providing actual website. The storage account is used to store the MP3 files. Azure CDN provides caching for the website. Finally, there is an Azure Log Analytics workbook used to collect stats from the SWA and storage account to track traffic. 

## Prerequisites

You will need to have an existing GitHub repository with the website you want to use. If you want to use a custom domain, you will need to have it already set up ready to set up a CNAME for the SWA. 

