#!/bin/bash

BASE_URL="http://revue-frontend"
INTERVAL=0.001 
API_KEY="apikey-dev"  

while true; do
  curl -X GET "http://revue-frontend"
  sleep $INTERVAL
done
