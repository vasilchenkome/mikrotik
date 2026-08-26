#!/bin/bash

# Configuration
COUNTRY_CODE="ru"
ROUTE_COMMENT="country_ru"
GATEWAY="192.168.0.1"
OUTPUT_FILE="ru.rsc"
URL="https://raw.githubusercontent.com/ipverse/country-ip-blocks/refs/heads/master/country/${COUNTRY_CODE}/ipv4-aggregated.txt"

echo "Downloading IP list for ${COUNTRY_CODE}..."
IPS=$(curl -sL "$URL")

if [ -z "$IPS" ]; then
    echo "Error: Failed to download IP list or list is empty."
    exit 1
fi

echo "Generating MikroTik script..."

# Start with cleaning the existing routes
echo "/ip route remove [find comment=\"${ROUTE_COMMENT}\"]" > "$OUTPUT_FILE"

# Add each subnet as a static route via the configured gateway.
echo "/ip route" >> "$OUTPUT_FILE"
while read -r line; do
    if [[ ! -z "$line" && "$line" != "#"* ]]; then
        echo "add dst-address=$line gateway=${GATEWAY} comment=\"${ROUTE_COMMENT}\"" >> "$OUTPUT_FILE"
    fi
done <<< "$IPS"

echo "Done. Script saved to ${OUTPUT_FILE}"
