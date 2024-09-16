#!/bin/bash

URL="http://revue-auth/login"
USERNAME="user"
PASSWORD="user"
INTERVAL=1.5  # 500ms interval

DATA=$(cat <<EOF
{
  "username": "$USERNAME",
  "password": "$PASSWORD"
}
EOF
)

while true; do
  curl -X POST -H "Content-Type: application/json" -d "$DATA" "$URL"
  
  sleep $INTERVAL
done
