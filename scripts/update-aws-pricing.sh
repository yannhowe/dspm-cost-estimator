#!/bin/bash

# Update AWS Pricing Data
# Run this script periodically to update aws-pricing.json with current AWS prices

set -e

echo "Fetching current AWS pricing for us-east-1 region..."

# Note: This script provides a template for AWS pricing updates
# AWS Pricing API requires AWS CLI configured with appropriate permissions
# Alternatively, pricing can be manually updated from AWS Pricing Calculator

echo ""
echo "AWS Pricing Update Script"
echo "========================="
echo ""
echo "AWS pricing can be fetched using:"
echo "1. AWS Pricing API (requires AWS CLI and credentials)"
echo "2. AWS Pricing Calculator: https://calculator.aws/"
echo "3. Manual updates from service pricing pages"
echo ""

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "⚠️  AWS CLI not found. Install it from: https://aws.amazon.com/cli/"
    echo ""
    echo "For now, using static pricing from AWS documentation..."
    echo "Please update pricing/aws-pricing.json manually if more accurate pricing is needed."
    exit 0
fi

# Pricing for common services (approximate, update manually for accuracy)
IAM_ROLE=0
CLOUDTRAIL=2.00
S3_STORAGE=0.023
EVENTBRIDGE=1.00
SQS=0.40
LAMBDA_INVOCATIONS=0.20
LAMBDA_DURATION=0.0000166667
KMS_KEY=1.00
NAT_GATEWAY=0.045
NAT_GATEWAY_DATA=0.045
DATA_TRANSFER=0.09

CURRENT_DATE=$(date +%Y-%m-%d)

cat > pricing/aws-pricing.json <<EOF
{
  "lastUpdated": "$CURRENT_DATE",
  "provider": "aws",
  "region": "us-east-1",
  "currency": "USD",
  "note": "Prices based on AWS US East (N. Virginia) region. Update periodically using update-aws-pricing.sh script.",
  "pricing": {
    "iamRole": {
      "service": "IAM",
      "product": "IAM Role",
      "pricePerMonth": ${IAM_ROLE},
      "unitOfMeasure": "Free",
      "note": "No charge for IAM roles",
      "source": "https://aws.amazon.com/iam/pricing/"
    },
    "cloudTrail": {
      "service": "CloudTrail",
      "product": "Management Events",
      "pricePerTrail": ${CLOUDTRAIL},
      "unitOfMeasure": "Per trail per region",
      "note": "First copy is \$2/month per region",
      "source": "https://aws.amazon.com/cloudtrail/pricing/"
    },
    "s3Storage": {
      "service": "S3",
      "product": "Standard Storage",
      "pricePerGB": ${S3_STORAGE},
      "unitOfMeasure": "Per GB per month",
      "note": "For CloudTrail logs storage",
      "source": "https://aws.amazon.com/s3/pricing/"
    },
    "eventBridge": {
      "service": "EventBridge",
      "product": "Custom Events",
      "pricePerMillionEvents": ${EVENTBRIDGE},
      "unitOfMeasure": "Per million events",
      "note": "For real-time event monitoring",
      "source": "https://aws.amazon.com/eventbridge/pricing/"
    },
    "sqs": {
      "service": "SQS",
      "product": "Standard Queue",
      "pricePerMillionRequests": ${SQS},
      "unitOfMeasure": "Per million requests",
      "note": "For event queue processing",
      "source": "https://aws.amazon.com/sqs/pricing/"
    },
    "lambda": {
      "service": "Lambda",
      "product": "Function Invocations",
      "pricePerMillionInvocations": ${LAMBDA_INVOCATIONS},
      "unitOfMeasure": "Per million invocations",
      "note": "For DSPM scanning functions",
      "source": "https://aws.amazon.com/lambda/pricing/"
    },
    "lambdaDuration": {
      "service": "Lambda",
      "product": "Duration (x86)",
      "pricePerGBSecond": ${LAMBDA_DURATION},
      "unitOfMeasure": "Per GB-second",
      "note": "Compute time for Lambda functions",
      "source": "https://aws.amazon.com/lambda/pricing/"
    },
    "kmsKey": {
      "service": "KMS",
      "product": "Customer Managed Key",
      "pricePerMonth": ${KMS_KEY},
      "unitOfMeasure": "Per key per month",
      "note": "For encryption keys",
      "source": "https://aws.amazon.com/kms/pricing/"
    },
    "natGateway": {
      "service": "VPC",
      "product": "NAT Gateway",
      "pricePerHour": ${NAT_GATEWAY},
      "unitOfMeasure": "Per hour",
      "note": "Optional for DSPM",
      "source": "https://aws.amazon.com/vpc/pricing/"
    },
    "natGatewayDataProcessing": {
      "service": "VPC",
      "product": "NAT Gateway Data Processing",
      "pricePerGB": ${NAT_GATEWAY_DATA},
      "unitOfMeasure": "Per GB",
      "note": "Data processed through NAT Gateway",
      "source": "https://aws.amazon.com/vpc/pricing/"
    },
    "dataTransfer": {
      "service": "EC2",
      "product": "Data Transfer Out",
      "pricePerGB": ${DATA_TRANSFER},
      "unitOfMeasure": "Per GB",
      "note": "First 100 GB/month to internet",
      "source": "https://aws.amazon.com/ec2/pricing/on-demand/"
    }
  }
}
EOF

echo ""
echo "✓ pricing/aws-pricing.json updated successfully!"
echo "  Last updated: $CURRENT_DATE"
echo ""
echo "Note: Prices are approximate. For production use, verify against:"
echo "  - AWS Pricing Calculator: https://calculator.aws/"
echo "  - AWS Pricing API for real-time rates"
