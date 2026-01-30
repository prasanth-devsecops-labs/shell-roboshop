#!/bin/bash

# Requirements:
# 1. Create ec2 instance using AWS CLI, for that need to configure AWS CLI with below steps
# 2. Create IAM user example: shell user and give full permissions to the user
# 3. Create access keys from the user, ID and PASSWORD store/download in private space.
# 4. Run 'aws configure' in ec2 instance and provide details ID, KEY, Region details.
# 5. Now you are able use cli, to confirm just run aws in terminal.

# 6. Get the aws cli commandline for creating ec2 instance and pass relevant arguments like
#    ami_id, sg_id, tags
# 7. Get the cli commandline to update the dns records with pvt ip of instances
# 8. Capture private IP and public IP in a variable.



AMI_ID="ami-0220d79f3f480ecf5"
SECURITY_GROUP_ID="sg-0dbaf5aed02fed09e"
HOSTED_ZONE_ID="Z082901534H7OC4NT02WB"
DOMAIN_NAME="prashum.online"

for instance in $@
do
    EXISTING_ID=$(aws ec2 describe-instances \
            --filters "Name=tag:Name,Values=$instance" "Name=instance-state-name,Values=running,pending" \
            --query 'Reservations[].Instances[].InstanceId' \
            --output text)

    if [ -n "$EXISTING_ID" ]; then
        echo "Instance for $instance already exists ($EXISTING_ID). Skipping creation."
        INSTANCE_ID=$EXISTING_ID
    else
        echo "Creating new instance for $instance..."
        INSTANCE_ID=$(aws ec2 run-instances \
        --image-id $AMI_ID \
        --instance-type t3.micro \
        --security-group-ids $SECURITY_GROUP_ID \
        --query 'Instances[0].InstanceId' \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
        --output text)

        aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"
    fi

    if [ $instance == "frontend" ]; then
        IP=$(aws ec2 describe-instances \
        --instance-ids $INSTANCE_ID \
        --query "Reservations[].Instances[].PublicIpAddress" --output text)

        RECORD_NAME="$DOMAIN_NAME"
    else
        IP=$(aws ec2 describe-instances \
        --instance-ids $INSTANCE_ID \
        --query "Reservations[].Instances[].PrivateIpAddress" --output text)

        RECORD_NAME="$instance.$DOMAIN_NAME"
    fi

    echo "IP Address is : $IP"

    aws route53 change-resource-record-sets \
    --hosted-zone-id "$HOSTED_ZONE_ID" \
    --change-batch "{
        \"Comment\": \"Updating record\",
        \"Changes\": [
            {
                \"Action\": \"UPSERT\",
                \"ResourceRecordSet\": {
                    \"Name\": \"$RECORD_NAME\",
                    \"Type\": \"A\",
                    \"TTL\": 1,
                    \"ResourceRecords\": [
                        {
                            \"Value\": \"$IP\"
                        }
                    ]
                }
            }
        ]
    }"

    echo "Records updated for $instance"

done
