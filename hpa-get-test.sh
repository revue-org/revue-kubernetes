#!/bin/bash

# Define variables
BASE_URL="http://revue-auth"
INTERVAL=0.1  # 500ms interval
API_KEY="apikey-dev"  # Bearer Token

# Infinite loop to send requests every 500ms
while true; do
  # Send GET request to /permissions with Bearer Token in header
  curl -X GET "$BASE_URL/permissions" \
    -H "Authorization: Bearer $API_KEY"

  # Send GET request to /users with Bearer Token in header
  curl -X GET "$BASE_URL/users" \
    -H "Authorization: Bearer $API_KEY"
  
  # Wait for 500ms before repeating
  sleep $INTERVAL
done
