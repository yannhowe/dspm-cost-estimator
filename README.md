# CrowdStrike Multi-Cloud Cost Calculator

A comprehensive cost calculator for estimating monthly infrastructure costs when using CrowdStrike Falcon Cloud Security across Azure, AWS, and GCP. Supports multiple features including IOMs (Indicators of Misconfiguration), Real-time Visibility & Detection, and DSPM (Data Security Posture Management).

## 🚀 Live Demo

**[Try it now →](https://yannhowe.github.io/dspm-cost-estimator/)**

## Features

- **Multi-cloud support** - Azure, AWS, and GCP cost estimation
- **Multiple security features** - IOMs, Real-time Visibility, and DSPM
- **Real-time pricing** from cloud provider pricing APIs
- **Accurate cost modeling** based on official CrowdStrike deployment templates
- **Feature toggles** - Enable only the features you plan to use
- **Detailed cost breakdown** with optimization tips
- **Responsive design** - Works on mobile and desktop

## 🛡️ Supported Features

### Azure

#### 1. Indicators of Misconfiguration (IOMs)
**Always enabled** - Asset inventory and configuration compliance monitoring

- Virtual Networks (free)
- Custom RBAC roles (free)
- **Cost: $0/month**

#### 2. Real-time Visibility & Detection
Event-driven monitoring using Event Hubs for IOA (Indicator of Attack) detection

- Event Hubs namespace (shared infrastructure)
- Configurable throughput units (1-20 TU)
- Storage accounts for logs (legacy registrations)
- Diagnostic settings (free)
- **Cost: ~$30/month base** (shared across all subscriptions)
- **Note**: Cost does NOT scale per subscription, but throughput may need adjustment based on total log volume

#### 3. Data Security Posture Management (DSPM)
Sensitive data scanning and classification

**Scanning Modes (April 2026+):**
- **Per-account scanning:** Infrastructure deployed to every subscription (original model)
- **Cross-account scanning (NEW):** Infrastructure deployed only to a designated host subscription — dramatically reduces always-on costs for multi-subscription environments
- **Use your own VNet (NEW):** For cross-account mode, skip VNet/NAT Gateway/Public IP/NSG provisioning entirely

**Resources:**
- Key Vault (negligible cost, 1 per subscription regardless of mode)
- Private Endpoint (~$7/month per region per host subscription)
- Virtual Network (free)
- NAT Gateway (optional, ~$33/month per region per host subscription)
- Public IP (conditional with NAT Gateway, ~$4/month)
- Scanner VMs (runtime only, ~$0.406/hour)

**Per-account cost:** ~$44/month per subscription per region (with NAT Gateway)
**Cross-account cost:** ~$44/month per region (host subscription only) + negligible Key Vault per sub

### AWS
Coming soon - Asset Inventory, Real-time Visibility, and DSPM features

### GCP
Coming soon - Asset Inventory, Real-time Visibility, and DSPM features

## 📊 Azure Cost Examples

### Example 1: IOMs Only (10 subscriptions)
- IOMs enabled: **$0/month** (free resources only)
- **Total: $0/month**

### Example 2: IOMs + Real-time Visibility (50 subscriptions)
- IOMs: $0/month
- Real-time Visibility (2 TU): ~$30/month (shared)
- **Total: ~$30/month** for entire organization

### Example 3: All Features (30 subscriptions, 1 region each, quarterly DSPM scans, per-account)
- IOMs: $0/month
- Real-time Visibility (2 TU): ~$30/month (shared)
- DSPM with NAT Gateway: ~$1,320/month (30 × $44)
- **Total: ~$1,350/month**

### Example 4: All Features Without NAT Gateway (Same as Example 3)
- IOMs: $0/month
- Real-time Visibility: ~$30/month
- DSPM without NAT Gateway: ~$246/month (30 × $8.20)
- **Total: ~$276/month**
- **Savings: ~$1,074/month (80%)**

### Example 5: Cross-account Scanning (30 subscriptions, 2 regions, quarterly DSPM)
- IOMs: $0/month
- Real-time Visibility (2 TU): ~$30/month (shared)
- DSPM cross-account with NAT Gateway: ~$88/month (1 host × 2 regions × $44)
- **Total: ~$118/month**
- **Savings vs per-account: ~$2,510/month (96%)**

## 🔧 Cost Optimization Tips

### Azure

#### 1. Use Cross-account Scanning for DSPM (NEW - April 2026)
**Save 90%+ on DSPM infrastructure costs for multi-subscription environments**

- Per-account: $44/month × N subscriptions × M regions
- Cross-account: $44/month × 1 host × M regions
- Same scanning coverage — scanner reaches into other subscriptions remotely
- Combine with "use your own VNet" for maximum savings

#### 2. Remove NAT Gateway for DSPM
**Save 70-82% on DSPM infrastructure costs**

- With NAT Gateway: $44/month per subscription per region
- Without NAT Gateway: $8-10/month per subscription per region
- Same security posture and scanning functionality
- Trade-off: Loss of centralized outbound IP address

Configuration:
```bicep
agentlessScanningDeployNatGateway: false
```

#### 3. Right-size Event Hub Throughput Units
- Start with 2 TU (default)
- Monitor throughput metrics
- Scale based on total log volume across all subscriptions
- Cost: $11/month per TU (shared infrastructure)

#### 4. Optimize DSPM Scanning
- Use quarterly scans (default) for compliance
- Only scan regions where sensitive data resides
- Consolidate subscriptions where possible

## 📚 Documentation References

### Azure Resources

**IOMs & Real-time Visibility:**
- [Resources Created When Registering Azure Accounts](https://falcon.crowdstrike.com/documentation/page/ec520d9c/resources-created-when-registering-azure-accounts)
- [Event Hub Bicep Template](https://github.com/CrowdStrike/azure-bicep-cloud-registration/blob/main/modules/log-ingestion/eventHub.bicep)

**DSPM:**
- [Official Bicep Templates](https://github.com/CrowdStrike/azure-bicep-cloud-registration)
- [DSPM Cost Estimation](https://docs.crowdstrike.com/r/ka120384)
- [Agentless Scanning Infrastructure Options for Azure](https://docs.crowdstrike.com/r/rc171502)
- [Configure DSPM Scans](https://falcon.crowdstrike.com/documentation/page/n71e95b3/configure-dspm-scans)

### AWS Resources
- [Terraform AWS Cloud Registration](https://github.com/CrowdStrike/terraform-aws-cloud-registration)

### Pricing Resources

**Azure:**
- [Azure Retail Prices API](https://learn.microsoft.com/en-us/rest/api/cost-management/retail-prices/azure-retail-prices)
- [Event Hubs Pricing](https://azure.microsoft.com/en-us/pricing/details/event-hubs/)
- [Private Link Pricing](https://azure.microsoft.com/en-us/pricing/details/private-link/)
- [NAT Gateway Pricing](https://azure.microsoft.com/en-us/pricing/details/azure-nat-gateway/)
- [Virtual Machines Pricing](https://azure.microsoft.com/en-us/pricing/details/virtual-machines/series/)

**AWS:**
- [AWS Pricing Calculator](https://calculator.aws/)
- [CloudTrail Pricing](https://aws.amazon.com/cloudtrail/pricing/)
- [Lambda Pricing](https://aws.amazon.com/lambda/pricing/)

**GCP:**
- [Google Cloud Pricing Calculator](https://cloud.google.com/products/calculator)
- [Cloud Logging Pricing](https://cloud.google.com/stackdriver/pricing)
- [Pub/Sub Pricing](https://cloud.google.com/pubsub/pricing)

## 🚀 Usage

1. Select your cloud provider (Azure, AWS, or GCP)
2. Choose which features to enable
3. Enter your environment details:
   - Number of subscriptions/accounts/projects
   - Number of regions
   - Feature-specific configurations
4. Click "Calculate Costs"
5. Review the detailed cost breakdown

## 💻 Technical Details

### Architecture
- **Single-file HTML** - No build process required
- **Client-side only** - No backend needed
- **Static pricing data** - Loaded from JSON files (updated periodically)
- **Dynamic tabs** - Fast cloud provider switching
- **Modular calculators** - Separate calculation logic per feature per cloud

### File Structure
```
dspm-cost-estimator/
├── index.html                      # Main calculator application
├── pricing/
│   ├── azure-pricing.json          # Azure pricing data
│   ├── aws-pricing.json            # AWS pricing data
│   └── gcp-pricing.json            # GCP pricing data
├── scripts/
│   ├── update-azure-pricing.sh     # Azure pricing updater
│   ├── update-aws-pricing.sh       # AWS pricing updater
│   └── update-gcp-pricing.sh       # GCP pricing updater
└── README.md                       # This file
```

### Updating Pricing Data

To update cloud provider pricing, run the appropriate script:

**Azure:**
```bash
cd dspm-cost-estimator
./scripts/update-azure-pricing.sh
```

**AWS:**
```bash
./scripts/update-aws-pricing.sh
```

**GCP:**
```bash
./scripts/update-gcp-pricing.sh
```

**Note**:
- Azure script fetches real-time pricing from Azure Retail Prices API
- AWS and GCP scripts use static pricing from documentation (manual updates recommended)
- Prices are based on US regions (US East for Azure/AWS, us-east1 for GCP)
- Regional price variations typically within 5-10%

## 🏗️ Deploy to GitHub Pages

1. Fork or clone this repository
2. Go to Settings → Pages
3. Select branch (main) and root directory
4. Save and visit your GitHub Pages URL

## 📝 Cost Modeling Accuracy

✅ **Verified against official CrowdStrike deployment templates**
✅ **All resources and features accounted for**
✅ **Shared vs. per-subscription infrastructure correctly modeled**
✅ **Cloud provider published pricing rates**
✅ **Conservative estimates with data transfer buffers**

**Important Notes:**
- Estimates are for infrastructure costs only
- Actual costs may vary based on:
  - Data volume and log generation rates
  - Network egress patterns
  - Regional pricing variations
  - Specific cloud provider agreements
  - Free tier eligibility (AWS/GCP)

For production cost planning and optimization guidance, contact your CrowdStrike Technical Account Manager.

## 🤝 Contributing

Contributions welcome! To update pricing or add features:

1. Update relevant pricing JSON files
2. Modify feature calculators in `index.html`
3. Test calculations thoroughly
4. Submit pull request

## 📄 License

MIT License - See LICENSE file for details

---

*This tool is not officially affiliated with or endorsed by CrowdStrike, Microsoft Azure, Amazon Web Services, or Google Cloud Platform. Resource deployment details are based on publicly available templates and documentation.*
