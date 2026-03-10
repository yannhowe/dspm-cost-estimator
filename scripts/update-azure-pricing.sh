#!/bin/bash

# Update Azure Pricing Data
# Run this script periodically to update azure-pricing.json with current Azure prices

set -e

echo "Fetching current Azure pricing for East US region..."

# Fetch Private Endpoint pricing
echo "Fetching Private Endpoint pricing..."
PRIVATE_ENDPOINT=$(curl -s "https://prices.azure.com/api/retail/prices?\$filter=serviceName%20eq%20'Private%20Link'%20and%20armRegionName%20eq%20'eastus'%20and%20priceType%20eq%20'Consumption'" | \
  jq -r '.Items[] | select(.productName | contains("Private Endpoint")) | .retailPrice' | head -1)

# Fetch NAT Gateway pricing
echo "Fetching NAT Gateway pricing..."
NAT_GATEWAY=$(curl -s "https://prices.azure.com/api/retail/prices?\$filter=serviceName%20eq%20'Virtual%20Network'%20and%20productName%20eq%20'NAT%20Gateway'%20and%20armRegionName%20eq%20'eastus'%20and%20priceType%20eq%20'Consumption'" | \
  jq -r '.Items[0].retailPrice')

# Fetch Public IP pricing
echo "Fetching Public IP pricing..."
PUBLIC_IP=$(curl -s "https://prices.azure.com/api/retail/prices?\$filter=serviceName%20eq%20'Virtual%20Network'%20and%20armRegionName%20eq%20'eastus'%20and%20priceType%20eq%20'Consumption'" | \
  jq -r '.Items[] | select(.productName | contains("Standard Static Public IP")) | .retailPrice' | head -1)

# Fetch VM F8s_v2 pricing
echo "Fetching Standard_F8s_v2 VM pricing..."
VM_PRICE=$(curl -s "https://prices.azure.com/api/retail/prices?\$filter=serviceName%20eq%20'Virtual%20Machines'%20and%20armRegionName%20eq%20'eastus'%20and%20priceType%20eq%20'Consumption'" | \
  jq -r '.Items[] | select(.armSkuName == "Standard_F8s_v2") | select(.productName | contains("Windows") | not) | .retailPrice' | head -1)

# Fetch Event Hub namespace pricing
echo "Fetching Event Hubs namespace pricing..."
EVENT_HUB_NAMESPACE=$(curl -s "https://prices.azure.com/api/retail/prices?\$filter=serviceName%20eq%20'Event%20Hubs'%20and%20armRegionName%20eq%20'eastus'%20and%20priceType%20eq%20'Consumption'" | \
  jq -r '.Items[] | select(.skuName == "Standard") | select(.productName | contains("Namespace")) | .retailPrice' | head -1)

# Fetch Event Hub throughput unit pricing
echo "Fetching Event Hubs throughput unit pricing..."
EVENT_HUB_TU=$(curl -s "https://prices.azure.com/api/retail/prices?\$filter=serviceName%20eq%20'Event%20Hubs'%20and%20armRegionName%20eq%20'eastus'%20and%20priceType%20eq%20'Consumption'" | \
  jq -r '.Items[] | select(.skuName == "Standard") | select(.productName | contains("Throughput")) | .retailPrice' | head -1)

echo ""
echo "Retrieved Pricing:"
echo "  Private Endpoint: \$$PRIVATE_ENDPOINT/hour"
echo "  NAT Gateway: \$$NAT_GATEWAY/hour"
echo "  Public IP: \$$PUBLIC_IP/hour"
echo "  VM Standard_F8s_v2: \$$VM_PRICE/hour"
echo "  Event Hub Namespace: \$$EVENT_HUB_NAMESPACE/hour"
echo "  Event Hub TU: \$$EVENT_HUB_TU/hour"

# Update the JSON file
CURRENT_DATE=$(date +%Y-%m-%d)

cat > pricing/azure-pricing.json <<EOF
{
  "lastUpdated": "$CURRENT_DATE",
  "region": "East US",
  "currency": "USD",
  "note": "Prices based on Azure US East region. Update periodically using update-pricing.sh script.",
  "pricing": {
    "privateEndpoint": {
      "service": "Private Link",
      "product": "Private Endpoint",
      "pricePerHour": ${PRIVATE_ENDPOINT:-0.01},
      "unitOfMeasure": "1 Hour",
      "source": "https://azure.microsoft.com/en-us/pricing/details/private-link/"
    },
    "natGateway": {
      "service": "Virtual Network",
      "product": "NAT Gateway",
      "pricePerHour": ${NAT_GATEWAY:-0.045},
      "unitOfMeasure": "1 Hour",
      "source": "https://azure.microsoft.com/en-us/pricing/details/azure-nat-gateway/"
    },
    "publicIp": {
      "service": "Virtual Network",
      "product": "IP Addresses - Standard Static Public IP",
      "pricePerHour": ${PUBLIC_IP:-0.005},
      "unitOfMeasure": "1 Hour",
      "source": "https://azure.microsoft.com/en-us/pricing/details/ip-addresses/"
    },
    "virtualMachine": {
      "service": "Virtual Machines",
      "product": "Standard_F8s_v2",
      "pricePerHour": ${VM_PRICE:-0.406},
      "unitOfMeasure": "1 Hour",
      "vcpus": 8,
      "memory": "16 GiB",
      "source": "https://azure.microsoft.com/en-us/pricing/details/virtual-machines/linux/"
    },
    "virtualNetwork": {
      "service": "Virtual Network",
      "product": "Virtual Network",
      "pricePerHour": 0,
      "unitOfMeasure": "Free",
      "source": "https://azure.microsoft.com/en-us/pricing/details/virtual-network/"
    },
    "keyVault": {
      "service": "Key Vault",
      "product": "Standard - Secret Operations",
      "pricePer10kOperations": 0.03,
      "unitOfMeasure": "10,000 operations",
      "source": "https://azure.microsoft.com/en-us/pricing/details/key-vault/"
    },
    "bandwidth": {
      "service": "Bandwidth",
      "product": "Data Transfer Out - First 100 GB",
      "pricePerGB": 0.087,
      "unitOfMeasure": "1 GB",
      "source": "https://azure.microsoft.com/en-us/pricing/details/bandwidth/"
    },
    "natGatewayDataProcessing": {
      "service": "NAT Gateway",
      "product": "Data Processed",
      "pricePerGB": 0.045,
      "unitOfMeasure": "1 GB",
      "source": "https://azure.microsoft.com/en-us/pricing/details/azure-nat-gateway/"
    },
    "eventHubNamespace": {
      "service": "Event Hubs",
      "product": "Standard Namespace",
      "pricePerHour": ${EVENT_HUB_NAMESPACE:-0.011},
      "unitOfMeasure": "1 Hour",
      "note": "Base cost for Event Hubs namespace (shared across all subscriptions)",
      "source": "https://azure.microsoft.com/en-us/pricing/details/event-hubs/"
    },
    "eventHubThroughputUnit": {
      "service": "Event Hubs",
      "product": "Throughput Unit",
      "pricePerHour": ${EVENT_HUB_TU:-0.015},
      "unitOfMeasure": "1 Hour per TU",
      "note": "1-20 TU configurable, shared across all subscriptions",
      "source": "https://azure.microsoft.com/en-us/pricing/details/event-hubs/"
    },
    "storageAccount": {
      "service": "Storage Accounts",
      "product": "General Purpose v2 - LRS",
      "pricePerMonth": 5.0,
      "unitOfMeasure": "Per account",
      "note": "For Function logs (legacy registrations only)",
      "source": "https://azure.microsoft.com/en-us/pricing/details/storage/"
    },
    "diagnosticSettings": {
      "service": "Azure Monitor",
      "product": "Diagnostic Settings",
      "pricePerHour": 0,
      "unitOfMeasure": "Free",
      "note": "No charge for diagnostic settings configuration",
      "source": "https://azure.microsoft.com/en-us/pricing/details/monitor/"
    },
    "rbacRole": {
      "service": "Azure RBAC",
      "product": "Custom Role",
      "pricePerHour": 0,
      "unitOfMeasure": "Free",
      "note": "No charge for RBAC roles",
      "source": "https://azure.microsoft.com/en-us/pricing/details/active-directory/"
    }
  }
}
EOF

echo ""
echo "✓ pricing/azure-pricing.json updated successfully!"
echo "  Last updated: $CURRENT_DATE"
