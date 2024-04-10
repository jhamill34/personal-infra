LOCATION="dist"
BUCKET_NAME="<your bucket name>"
CLOUDFRONT_ID="<your cloudfront id>"
REGION="us-east-1"

aws s3 sync $LOCATION s3://$BUCKET_NAME --delete --region $REGION

aws cloudfront create-invalidation \
    --distribution-id $CLOUDFRONT_ID \
    --paths "/*" \
    --region $REGION

