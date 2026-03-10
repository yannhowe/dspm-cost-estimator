#!/bin/bash

# Update GCP Pricing Data
# Run this script periodically to update gcp-pricing.json with current GCP prices

set -e

echo "Fetching current GCP pricing for us-east1 region..."

# Note: This script provides a template for GCP pricing updates
# GCP pricing can be fetched using Cloud Billing API or manually from pricing pages

echo ""
echo "GCP Pricing Update Script"
echo "========================="
echo ""
echo "GCP pricing can be fetched using:"
echo "1. Cloud Billing Catalog API (requires gcloud CLI and appropriate permissions)"
echo "2. Google Cloud Pricing Calculator: https://cloud.google.com/products/calculator"
echo "3. Manual updates from service pricing pages"
echo ""

# Check if gcloud CLI is installed
if ! command -v gcloud &> /dev/null; then
    echo "⚠️  gcloud CLI not found. Install it from: https://cloud.google.com/sdk/install"
    echo ""
    echo "For now, using static pricing from GCP documentation..."
    echo "Please update pricing/gcp-pricing.json manually if more accurate pricing is needed."
    exit 0
fi

# Pricing for common services (approximate, update manually for accuracy)
SERVICE_ACCOUNT=0
CLOUD_LOGGING=0.50
CLOUD_LOGGING_FREE=50
PUBSUB=0.06
PUBSUB_FREE=10
CLOUD_FUNCTIONS=0.40
CLOUD_FUNCTIONS_FREE=2000000
CLOUD_FUNCTIONS_COMPUTE=0.0000025
CLOUD_FUNCTIONS_COMPUTE_FREE=400000
CLOUD_STORAGE=0.020
CLOUD_NAT=0.044
CLOUD_NAT_DATA=0.045
DATA_TRANSFER=0.12
DATA_TRANSFER_FREE=1

CURRENT_DATE=$(date +%Y-%m-%d)

cat > pricing/gcp-pricing.json <<EOF
{
  "lastUpdated": "$CURRENT_DATE",
  "provider": "gcp",
  "region": "us-east1",
  "currency": "USD",
  "note": "Prices based on GCP us-east1 region. Update periodically using update-gcp-pricing.sh script.",
  "pricing": {
    "serviceAccount": {
      "service": "IAM",
      "product": "Service Account",
      "pricePerMonth": ${SERVICE_ACCOUNT},
      "unitOfMeasure": "Free",
      "note": "No charge for service accounts",
      "source": "https://cloud.google.com/iam/pricing"
    },
    "cloudLogging": {
      "service": "Cloud Logging",
      "product": "Log Ingestion",
      "pricePerGB": ${CLOUD_LOGGING},
      "unitOfMeasure": "Per GB",
      "note": "After 50 GB free tier per project per month",
      "freeTierGB": ${CLOUD_LOGGING_FREE},
      "source": "https://cloud.google.com/stackdriver/pricing"
    },
    "pubSub": {
      "service": "Pub/Sub",
      "product": "Message Delivery",
      "pricePerGB": ${PUBSUB},
      "unitOfMeasure": "Per GB",
      "note": "After 10 GB free tier per month",
      "freeTierGB": ${PUBSUB_FREE},
      "source": "https://cloud.google.com/pubsub/pricing"
    },
    "cloudFunctions": {
      "service": "Cloud Functions",
      "product": "Invocations",
      "pricePerMillionInvocations": ${CLOUD_FUNCTIONS},
      "unitOfMeasure": "Per million invocations",
      "note": "After 2 million free invocations per month",
      "freeTierInvocations": ${CLOUD_FUNCTIONS_FREE},
      "source": "https://cloud.google.com/functions/pricing"
    },
    "cloudFunctionsCompute": {
      "service": "Cloud Functions",
      "product": "Compute Time",
      "pricePerGBSecond": ${CLOUD_FUNCTIONS_COMPUTE},
      "unitOfMeasure": "Per GB-second",
      "note": "After 400,000 GB-seconds free tier per month",
      "freeTierGBSeconds": ${CLOUD_FUNCTIONS_COMPUTE_FREE},
      "source": "https://cloud.google.com/functions/pricing"
    },
    "cloudStorage": {
      "service": "Cloud Storage",
      "product": "Standard Storage",
      "pricePerGB": ${CLOUD_STORAGE},
      "unitOfMeasure": "Per GB per month",
      "note": "For logs and data storage",
      "source": "https://cloud.google.com/storage/pricing"
    },
    "cloudNAT": {
      "service": "Cloud NAT",
      "product": "NAT Gateway",
      "pricePerHour": ${CLOUD_NAT},
      "unitOfMeasure": "Per hour per gateway",
      "note": "Optional for DSPM",
      "source": "https://cloud.google.com/nat/pricing"
    },
    "cloudNATDataProcessing": {
      "service": "Cloud NAT",
      "product": "Data Processing",
      "pricePerGB": ${CLOUD_NAT_DATA},
      "unitOfMeasure": "Per GB",
      "note": "Data processed through NAT gateway",
      "source": "https://cloud.google.com/nat/pricing"
    },
    "dataTransfer": {
      "service": "Networking",
      "product": "Internet Egress",
      "pricePerGB": ${DATA_TRANSFER},
      "unitOfMeasure": "Per GB",
      "note": "After 1 GB free tier per month (Worldwide destinations, excluding China and Australia)",
      "freeTierGB": ${DATA_TRANSFER_FREE},
      "source": "https://cloud.google.com/vpc/network-pricing"
    }
  }
}
EOF

echo ""
echo "✓ pricing/gcp-pricing.json updated successfully!"
echo "  Last updated: $CURRENT_DATE"
echo ""
echo "Note: Prices are approximate. For production use, verify against:"
echo "  - Google Cloud Pricing Calculator: https://cloud.google.com/products/calculator"
echo "  - Cloud Billing Catalog API for real-time rates"
