#!/bin/bash
# set -ex
# Set the variables below to use make cloudflare-update
# CLOUDFLARE_TOKEN=xxxxxxx
# ZONE_ID=yyyyyy
# RECORD=minecraft.domain.com

if [ ! -z "$CLOUDFLARE_TOKEN" ] || [ ! -z "$ZONE_ID" ] || [ ! -z "$RECORD" ]; then

     if [ ! "$AWS_INSTANCE_PUBLIC_IP" == "null" ] ; then

          DNS_RECORD_ID=$(curl -s "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=A&name=$RECORD" \
               -H "Authorization: Bearer $CLOUDFLARE_TOKEN" \
               -H "Content-Type: application/json" |  jq -r .result[0].id)

          curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$DNS_RECORD_ID" \
               -H "Authorization: Bearer $CLOUDFLARE_TOKEN" \
               -H "Content-Type: application/json" \
               --data "{\"type\":\"A\",\"name\":\"$RECORD\",\"content\":\"$AWS_INSTANCE_PUBLIC_IP\",\"ttl\":360,\"proxied\":false}"

     else
          echo "\nenv var AWS_INSTANCE_PUBLIC_IP is null. Check if instance ir running or ec2 tf file output is correct."
     fi
else
     echo "\nSet env vars on cloudflare-update.sh or check the set values"
fi