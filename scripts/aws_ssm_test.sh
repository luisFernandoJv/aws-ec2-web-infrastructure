#!/bin/bash

# ============================================================
#  update-website.sh
#  Deploy script — AWS S3 Static Website
#  Author: Luís Fernando Alexandre dos Santos
#  Description: Syncs local static website files to S3 bucket.
#               Only modified files are uploaded (aws s3 sync).
# ============================================================

BUCKET_NAME="luis-alexandre-cafe-2026"
LOCAL_DIR="/home/ec2-user/sysops-activity-files/static-website/"
REGION="us-west-2"

echo "============================================"
echo "  Starting deployment to S3..."
echo "  Bucket : s3://$BUCKET_NAME"
echo "  Source : $LOCAL_DIR"
echo "  Region : $REGION"
echo "============================================"

aws s3 sync "$LOCAL_DIR" "s3://$BUCKET_NAME/" \
  --acl public-read \
  --region "$REGION"

if [ $? -eq 0 ]; then
  echo ""
  echo "✅ Deployment successful!"
  echo "🌐 Website URL: http://$BUCKET_NAME.s3-website-$REGION.amazonaws.com"
else
  echo ""
  echo "❌ Deployment failed. Check your AWS credentials and bucket name."
  exit 1
fi