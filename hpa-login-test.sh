#!/bin/bash

# Define variables
URL="http://revue-auth/login"
USERNAME="user"
PASSWORD="user"
INTERVAL=1.5  # 500ms interval

# JSON payload
DATA=$(cat <<EOF
{
  "username": "$USERNAME",
  "password": "$PASSWORD"
}
EOF
)

# Infinite loop to send requests every 500ms
while true; do
  # Send POST request with JSON body
  curl -X POST -H "Content-Type: application/json" -d "$DATA" "$URL"
  
  # Wait for 500ms before sending the next request
  sleep $INTERVAL
done
