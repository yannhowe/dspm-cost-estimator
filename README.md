# CrowdStrike DSPM Cost Estimator for Azure

A simple cost calculator for estimating monthly Azure costs when using CrowdStrike's Data Security Posture Management (DSPM).

## 🚀 Live Demo

**[Try it now →](https://yourusername.github.io/dspm-cost-estimator/)**

## Features

- Real-time pricing from Azure Retail Prices API
- Calculate costs for multiple subscriptions and regions
- Toggle NAT Gateway for cost optimization
- Adjust scan frequency and duration
- Detailed cost breakdown with optimization tips

## Usage

Just open the page and enter:
- Number of Azure subscriptions
- Number of regions per subscription
- Scan frequency and duration

The calculator automatically fetches current Azure pricing and shows your estimated monthly cost.

## Deploy to GitHub Pages

1. Fork or clone this repository
2. Go to Settings → Pages
3. Select branch (main) and root directory
4. Save and visit your GitHub Pages URL

## About DSPM

CrowdStrike DSPM scans Azure storage resources for sensitive data. This tool helps estimate the infrastructure costs for running DSPM in your environment.

**Resources provisioned:**
- Key Vault (per subscription)
- Virtual Network + Private Endpoint (per region)
- NAT Gateway + Public IP (per region, optional)
- Azure VM Standard_F8s_v2 (scan-time only)

## Documentation

- [DSPM Cost Estimation](https://falcon.crowdstrike.com/documentation/page/jaf24dc6/dspm-cost-estimation)
- [Configure DSPM Scans](https://falcon.crowdstrike.com/documentation/page/n71e95b3/configure-dspm-scans)
- [Azure Retail Prices API](https://learn.microsoft.com/en-us/rest/api/cost-management/retail-prices/azure-retail-prices)

## License

MIT License - See LICENSE file for details

---

*Not affiliated with or endorsed by CrowdStrike. For official pricing guidance, contact your CrowdStrike Technical Account Manager.*
