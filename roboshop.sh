#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0b5711d20e4247352"
ZONE_ID="Z068292335UHLBA4CJHHW" #hosted zone id ON AWS
DOMAIN_NAME="zyna.space" 


for instance in "$@" ; #$@ is all the arguments passed in command line
do 
  INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)
    
    #get private or public ip based on frentend{public} or backend{private}
if [ "$instance" != "frontend" ]; then
    IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
    RECORD_NAME="$INSTANCE.DOMAIN_NAME"                     #mangodb.zyna.space,frontend.zyna.space
else
    IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    RECORD_NAME="$DOMAIN_NAME"  #zyna.space
fi
    echo "$instance  $IP"
     aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch " 
    {
        "Comment": "Updating record set"
        ,"Changes": [{
        "Action"              : "UPSERT"          #UPSERT will create or update
        ,"ResourceRecordSet"  : {
            "Name"              : "'$RECORD_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP'"
            }]
        }
        }]
    }
    "
done
 