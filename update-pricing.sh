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

echo ""
echo "Retrieved Pricing:"
echo "  Private Endpoint: \$$PRIVATE_ENDPOINT/hour"
echo "  NAT Gateway: \$$NAT_GATEWAY/hour"
echo "  Public IP: \$$PUBLIC_IP/hour"
echo "  VM Standard_F8s_v2: \$$VM_PRICE/hour"

# Update the JSON file
CURRENT_DATE=$(date +%Y-%m-%d)

cat > azure-pricing.json <<EOF
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
    }
  }
}
EOF

echo ""
echo "✓ azure-pricing.json updated successfully!"
echo "  Last updated: $CURRENT_DATE"
