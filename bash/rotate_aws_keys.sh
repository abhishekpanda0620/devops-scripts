#!/bin/bash

# Script to rotate AWS access keys

PROFILE="PROFILE or DEFAULT"
USER_NAME="IAM USER NAME"
REGION="REGION"
CREDENTIALS_FILE="$HOME/.aws/credentials"

echo "Rotating AWS access keys for user $USER_NAME..."

# List current access keys
OLD_KEY=$(aws iam list-access-keys --user-name "$USER_NAME" --profile "$PROFILE" --query 'AccessKeyMetadata[0].AccessKeyId' --output text)

if [ -z "$OLD_KEY" ] || [ "$OLD_KEY" == "None" ]; then
    echo "No existing access key found. Creating a new one..."
else
    echo "Found existing key: $OLD_KEY"
fi

# Create a new access key
NEW_KEY_JSON=$(aws iam create-access-key --user-name "$USER_NAME" --profile "$PROFILE")
NEW_ACCESS_KEY=$(echo "$NEW_KEY_JSON" | jq -r '.AccessKey.AccessKeyId')
NEW_SECRET_KEY=$(echo "$NEW_KEY_JSON" | jq -r '.AccessKey.SecretAccessKey')

if [ -z "$NEW_ACCESS_KEY" ]; then
    echo "Failed to create new access key"
    exit 1
fi

echo "New access key created: $NEW_ACCESS_KEY"

# Update credentials file
sed -i "/\[$PROFILE\]/,/^$/ { s/aws_access_key_id = .*/aws_access_key_id = $NEW_ACCESS_KEY/; s/aws_secret_access_key = .*/aws_secret_access_key = $NEW_SECRET_KEY/; }" "$CREDENTIALS_FILE"

# Delete old key if it exists
if [ -n "$OLD_KEY" ] && [ "$OLD_KEY" != "None" ]; then
    echo "Deleting old access key: $OLD_KEY"
    aws iam delete-access-key --user-name "$USER_NAME" --access-key-id "$OLD_KEY" --profile "$PROFILE"
fi

echo "Access key rotation completed!"