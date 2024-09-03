#!/bin/bash

source "../../instana.env"
source "../help-functions.sh"

INSTALL_HOME=$(get_make_install_home)

RAW_SPANS_S3_BUCKET_POLICY_FILENAME="raw-spans-s3-bucket-policy.json"

policy_file=$INSTALL_HOME/$RAW_SPANS_S3_BUCKET_POLICY_FILENAME

echo writing iam json policy for "$RAW_SPANS_S3_BUCKET_NAME" to $policy_file
echo

cat > $policy_file <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:CreateBucket",
                "s3:DeleteBucket",
                "s3:PutBucketTagging",
                "s3:GetBucketTagging",
                "s3:PutBucketPublicAccessBlock",
                "s3:GetBucketPublicAccessBlock",
                "s3:PutEncryptionConfiguration",
                "s3:GetEncryptionConfiguration",
                "s3:PutLifecycleConfiguration",
                "s3:GetLifecycleConfiguration",
                "s3:GetBucketLocation",
                "s3:ListBucket",
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:ListBucketMultipartUploads",
                "s3:AbortMultipartUpload",
                "s3:ListMultipartUploadParts"
            ],
	    "Resource": "$RAW_SPANS_S3_BUCKET_ARN"
        }
    ]
}
EOF
