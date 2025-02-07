#!/bin/bash

# Set AWS region
AWS_REGION="REGION"

# S3 bucket name
S3_BUCKET="BUCKET_NAME"

# Email configuration
SENDER_EMAIL="your-verified-email@domain.com"
RECIPIENT_EMAIL="recipient@domain.com"
EMAIL_SUBJECT="EBS Snapshot Backup Report"

# Log file
LOG_FILE="/var/log/ebs-backup-$(date +%Y-%m-%d).log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to send email using SES
send_email() {
    local body="$1"
    aws ses send-email \
        --region "$AWS_REGION" \
        --from "$SENDER_EMAIL" \
        --to "$RECIPIENT_EMAIL" \
        --subject "$EMAIL_SUBJECT" \
        --text "$body"
}

# Initialize email body
EMAIL_BODY="EBS Snapshot Backup Report\n\nBackup Date: $(date '+%Y-%m-%d %H:%M:%S')\n\n"

# Create log file
touch "$LOG_FILE"
log_message "Starting EBS snapshot backup process"

# Get all EC2 instances
INSTANCES=$(aws ec2 describe-instances \
    --region "$AWS_REGION" \
    --query 'Reservations[].Instances[].[InstanceId,Tags[?Key==`Name`].Value | [0]]' \
    --output text)

# Process each instance
while read -r INSTANCE_ID INSTANCE_NAME; do
    if [ -z "$INSTANCE_NAME" ]; then
        INSTANCE_NAME="unnamed-instance"
    fi
    
    log_message "Processing instance: $INSTANCE_NAME ($INSTANCE_ID)"
    EMAIL_BODY+="\nInstance: $INSTANCE_NAME ($INSTANCE_ID)\n"

    # Get all EBS volumes attached to the instance
    VOLUMES=$(aws ec2 describe-volumes \
        --region "$AWS_REGION" \
        --filters Name=attachment.instance-id,Values="$INSTANCE_ID" \
        --query 'Volumes[*].VolumeId' \
        --output text)

    for VOLUME_ID in $VOLUMES; do
        log_message "Creating snapshot for volume: $VOLUME_ID"
        
        # Create snapshot
        SNAPSHOT_ID=$(aws ec2 create-snapshot \
            --region "$AWS_REGION" \
            --volume-id "$VOLUME_ID" \
            --description "Backup of $INSTANCE_NAME - $VOLUME_ID" \
            --query 'SnapshotId' \
            --output text)

        if [ $? -eq 0 ]; then
            log_message "Snapshot created successfully: $SNAPSHOT_ID"
            
            # Wait for snapshot to complete
            aws ec2 wait snapshot-completed \
                --region "$AWS_REGION" \
                --snapshot-ids "$SNAPSHOT_ID"

            # Export snapshot to S3
            SNAPSHOT_FILE="${INSTANCE_NAME}/${VOLUME_ID}_$(date +%Y-%m-%d).snapshot"
            aws ec2 export-snapshot \
                --region "$AWS_REGION" \
                --snapshot-id "$SNAPSHOT_ID" \
                --s3-bucket "$S3_BUCKET" \
                --s3-prefix "$SNAPSHOT_FILE"

            EMAIL_BODY+="  Volume $VOLUME_ID -> Snapshot $SNAPSHOT_ID -> S3://$S3_BUCKET/$SNAPSHOT_FILE\n"
        else
            log_message "Failed to create snapshot for volume: $VOLUME_ID"
            EMAIL_BODY+="  Failed to create snapshot for volume: $VOLUME_ID\n"
        fi
    done
done <<< "$INSTANCES"

# Add completion message to email body
EMAIL_BODY+="\nBackup process completed at $(date '+%Y-%m-%d %H:%M:%S')"

# Send email notification
log_message "Sending email notification"
send_email "$EMAIL_BODY"

log_message "Backup process completed"
