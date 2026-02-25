# CrowdStrike DSPM Cost Estimator for Azure

A cost calculator for estimating monthly Azure infrastructure costs when using CrowdStrike's Data Security Posture Management (DSPM). Based on official Azure Bicep deployment templates and CrowdStrike documentation.

## 🚀 Live Demo

**[Try it now →](https://yannhowe.github.io/dspm-cost-estimator/)**

## Features

- **Real-time pricing** from Azure Retail Prices API
- **Accurate cost modeling** based on official CrowdStrike Bicep templates
- Calculate costs for multiple subscriptions and regions
- Toggle NAT Gateway for cost optimization (save ~70%)
- Adjust scan frequency and duration
- Detailed cost breakdown with optimization tips

## 📊 How Costs Are Calculated

The calculator models costs based on the official CrowdStrike Azure Bicep deployment templates. All resource costs are derived from actual Azure infrastructure that gets provisioned.

### Cost Formula

```
Total Monthly Cost =
  (Key Vault transaction costs - negligible) +
  (Private Endpoint × subscriptions × regions × 730 hrs) +
  (NAT Gateway × subscriptions × regions × 730 hrs) [if enabled] +
  (Public IP × subscriptions × regions × 730 hrs) [if NAT Gateway enabled] +
  (VM hours × scans per month × subscriptions × regions × VM hourly rate) +
  (Estimated data transfer)
```

**Key Vault costs are negligible** because:
- Standard tier has no base monthly fee
- Only charges $0.03 per 10,000 secret operations
- Scanner VMs read secrets only at scan start (~once per scan)
- Example: 100 subscriptions × quarterly scans = ~33 reads/month = $0.0001

### Resource Breakdown

#### Per Subscription (Always-On)

**Key Vault** - Stores CrowdStrike API credentials
- Template: [`scanningResourceGroup.bicep`](https://github.com/CrowdStrike/azure-bicep-cloud-registration/blob/main/modules/scanning-environment/scanningResourceGroup.bicep#L167-L189)
- Resource: `kv-cs-<hash>`
- SKU: Standard
- Contents: 1 secret (client-credentials with API client ID and secret)
- Cost Model: Transaction-based ($0.03 per 10,000 secret operations)
- **Actual Cost: Negligible** - Scanner VMs read secrets only at scan start
  - Example: 100 subs × 2 regions × 0.33 quarterly scans/month = 66 reads/month
  - Cost: 66 ÷ 10,000 × $0.03 = **$0.0002/month** (effectively free)
- **Note**: Key Vault Standard has no base monthly fee, only per-transaction costs

#### Per Region Per Subscription (Always-On)

**Private Endpoint** - Secure Key Vault access
- Template: [`scanningKeyVaultPrivateEndpoint.bicep`](https://github.com/CrowdStrike/azure-bicep-cloud-registration/blob/main/modules/scanning-environment/scanningKeyVaultPrivateEndpoint.bicep#L38-L63)
- Resource: `pep-csscanning-keyvault-<env>-<region>`
- Cost: ~$0.01/hour = $7.30/month per region
- **Why needed**: Allows scanner VMs to retrieve API credentials from Key Vault over private network

**Virtual Network** - Isolated scanning network
- Template: [`scanningRegion.bicep`](https://github.com/CrowdStrike/azure-bicep-cloud-registration/blob/main/modules/scanning-environment/scanningRegion.bicep#L78-L119)
- Resource: `vnet-csscanning-<env>-<region>` with 2 subnets
- Cost: Free

**NAT Gateway** (Optional) - Shared outbound IP for scanners
- Template: [`scanningRegion.bicep`](https://github.com/CrowdStrike/azure-bicep-cloud-registration/blob/main/modules/scanning-environment/scanningRegion.bicep#L55-L70)
- Resource: `ng-csscanning-scanners-<env>-<region>`
- Deployment: Controlled by `agentlessScanningDeployNatGateway` parameter (default: true)
- Cost: ~$0.045/hour = $32.85/month per region
- **Cost impact**: 70% of total infrastructure cost

**Public IP** (Conditional) - Static IP for NAT Gateway
- Template: [`scanningRegion.bicep`](https://github.com/CrowdStrike/azure-bicep-cloud-registration/blob/main/modules/scanning-environment/scanningRegion.bicep#L43-L53)
- Resource: `pip-csscanning-scanners-<env>-<region>`
- Deployment: **Only deployed if NAT Gateway is enabled** (conditional resource)
- Cost: ~$0.005/hour = $3.65/month per region
- **Note**: Without NAT Gateway, VMs get temporary public IPs during scans only

#### Scan-Time Resources (Temporary)

**Azure VM** - Data scanner
- Not in templates (provisioned at runtime by CrowdStrike)
- Size: Standard_F8s_v2 (8 vCPUs, 16 GiB RAM)
- Cost: ~$0.406/hour
- **Only charged during active scans**, automatically deleted after completion

### Cost Comparison

Example: 30 subscriptions, 1 region each, quarterly scans (4 hours each)

| Configuration | Monthly Cost | Key Resources |
|---------------|--------------|---------------|
| **With NAT Gateway** | ~$1,341 | Private EP ($219) + NAT GW ($986) + Public IP ($110) + Key Vault (~$0) |
| **Without NAT Gateway** | ~$246 | Private EP ($219) + Key Vault (~$0) + minimal scan-time costs |
| **Savings** | **~$1,095 (82%)** | Remove NAT Gateway + Public IP |

**Note**: Key Vault costs are effectively $0 in practice (transaction-based pricing, minimal operations).

## 🔧 Cost Optimization

### Remove NAT Gateway (Recommended)

**Save ~70-82% on infrastructure costs** by configuring DSPM without NAT Gateway.

**How it works:**
- **With NAT Gateway**: All scanner VMs share a single static public IP (24/7 cost)
- **Without NAT Gateway**: Each scanner VM gets a temporary public IP during scans only (minimal cost)

**Security:**
- Both configurations maintain the same security posture
- Private Endpoint still secures Key Vault access
- Scanner VMs still authenticate to CrowdStrike over HTTPS

**Trade-offs:**
- ❌ Lose centralized outbound IP address
- ✅ Same scanning functionality and quality
- ✅ 70-82% cost reduction

**How to configure:**
```bicep
// In your deployment parameters
agentlessScanningDeployNatGateway: false
```

See: [DSPM Network Configuration Documentation](https://falcon.crowdstrike.com/documentation/page/n71e95b3/configure-dspm-scans#t13b00f2)

### Other Optimizations

1. **Consolidate subscriptions** - Each subscription adds ~$44/month in infrastructure
2. **Limit regions** - Only scan regions where sensitive data resides
3. **Quarterly scanning** - Default and recommended frequency for compliance
4. **Optimize scan duration** - Adjust based on data volume (minimal impact on cost)

## 📚 References

### CrowdStrike Resources

- **Official Bicep Templates**: [azure-bicep-cloud-registration](https://github.com/CrowdStrike/azure-bicep-cloud-registration)
  - [scanningForSub.bicep](https://github.com/CrowdStrike/azure-bicep-cloud-registration/blob/main/modules/scanning-environment/scanningForSub.bicep) - Subscription-level deployment
  - [scanningRegion.bicep](https://github.com/CrowdStrike/azure-bicep-cloud-registration/blob/main/modules/scanning-environment/scanningRegion.bicep) - Regional infrastructure
  - [scanningResourceGroup.bicep](https://github.com/CrowdStrike/azure-bicep-cloud-registration/blob/main/modules/scanning-environment/scanningResourceGroup.bicep) - Key Vault and roles
  - [scanningKeyVaultPrivateEndpoint.bicep](https://github.com/CrowdStrike/azure-bicep-cloud-registration/blob/main/modules/scanning-environment/scanningKeyVaultPrivateEndpoint.bicep) - Private endpoint

- **Documentation**:
  - [DSPM Cost Estimation](https://falcon.crowdstrike.com/documentation/page/jaf24dc6/dspm-cost-estimation)
  - [Configure DSPM Scans](https://falcon.crowdstrike.com/documentation/page/n71e95b3/configure-dspm-scans)
  - [Azure Resources Provisioned for DSPM](https://falcon.crowdstrike.com/documentation/page/ec520d9c/resources-created-when-registering-azure-accounts#tbe58a1a)

### Azure Pricing

- [Key Vault Pricing](https://azure.microsoft.com/en-us/pricing/details/key-vault/)
- [Virtual Network Pricing](https://azure.microsoft.com/en-us/pricing/details/virtual-network/)
- [Private Link Pricing](https://azure.microsoft.com/en-us/pricing/details/private-link/)
- [NAT Gateway Pricing](https://azure.microsoft.com/en-us/pricing/details/azure-nat-gateway/)
- [IP Addresses Pricing](https://azure.microsoft.com/en-us/pricing/details/ip-addresses/)
- [Virtual Machine Pricing](https://azure.microsoft.com/en-us/pricing/details/virtual-machines/series/)
- [Azure Retail Prices API](https://learn.microsoft.com/en-us/rest/api/cost-management/retail-prices/azure-retail-prices)

## 🚀 Usage

Just open the page and enter:
- Number of Azure subscriptions to scan
- Number of regions per subscription
- Azure region for pricing reference
- Enable/disable NAT Gateway
- Scan frequency (quarterly, monthly, bi-weekly, weekly)
- Average scan duration per subscription

The calculator automatically fetches current Azure pricing and shows your estimated monthly cost.

## 🏗️ Deploy to GitHub Pages

1. Fork or clone this repository
2. Go to Settings → Pages
3. Select branch (main) and root directory
4. Save and visit your GitHub Pages URL

## 💻 Technical Details

- **Single-file HTML** - No build process required
- **Client-side only** - No backend needed
- **Static pricing data** - Loaded from `azure-pricing.json` (updated periodically)
- **Responsive design** - Works on mobile and desktop
- **US East region pricing** - Prices based on Azure US East; other regions may vary slightly

### Updating Pricing

To update Azure pricing data, run:

```bash
cd dspm-cost-estimator
./update-pricing.sh
```

This script fetches current pricing from Azure Retail Prices API and updates `azure-pricing.json`.

**Note:** Prices are based on Azure US East region. Pricing varies slightly by region (typically within 5-10%). For precise regional pricing, consult Azure's pricing calculator or your Azure billing.

## 📝 Cost Modeling Accuracy

✅ **Verified against official CrowdStrike Bicep templates**
✅ **All resources accounted for** (per subscription, per region, scan-time)
✅ **Conditional resource logic** (NAT Gateway, Public IP)
✅ **Azure published pricing rates**
✅ **Conservative estimates** (includes data transfer buffer)

**Note**: This calculator provides estimates for infrastructure costs. Actual costs may vary based on:
- Data volume scanned
- Network egress patterns
- **Azure region pricing variations** (calculator uses US East pricing)
- Specific subscription agreements

For production cost planning, contact your CrowdStrike Technical Account Manager.

## 📄 License

MIT License - See LICENSE file for details

---

*This tool is not officially affiliated with or endorsed by CrowdStrike. Resource deployment details are based on publicly available Bicep templates and documentation.*
