#!/bin/bash

# Define variables
BASE_URL="http://revue-auth"
INTERVAL=0.001 
API_KEY="apikey-dev"  # Bearer Token

while true; do
  curl -X GET "$BASE_URL/permissions" \
    -H "Authorization: Bearer $API_KEY"

  curl -X GET "$BASE_URL/users" \
    -H "Authorization: Bearer $API_KEY"
  
  sleep $INTERVAL
done
