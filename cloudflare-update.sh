#!/bin/bash
# Set the variables below to use make cloudflare-update
# CLOUDFLARE_TOKEN=xxxxxxx
# ZONE_ID=yyyyyy
# RECORD=minecraft.domain.com

DNS_RECORD_ID=$(curl -s "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=A&name=$RECORD" \
     -H "Authorization: Bearer $CLOUDFLARE_TOKEN" \
     -H "Content-Type: application/json" |  jq -r .result[0].id)

curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$DNS_RECORD_ID" \
     -H "Authorization: Bearer $CLOUDFLARE_TOKEN" \
     -H "Content-Type: application/json" \
     --data "{\"type\":\"A\",\"name\":\"$RECORD\",\"content\":\"$AWS_INSTANCE_PUBLIC_IP\",\"ttl\":360,\"proxied\":false}"