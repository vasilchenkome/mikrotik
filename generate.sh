#!/bin/bash

# Configuration
COUNTRY_CODE="ru"
LIST_NAME="country_ru"
OUTPUT_FILE="ru.rsc"
URL="https://raw.githubusercontent.com/ipverse/country-ip-blocks/master/country/${COUNTRY_CODE}/ipv4-aggregated.txt"

echo "Downloading IP list for ${COUNTRY_CODE}..."
IPS=$(curl -sL "$URL")

if [ -z "$IPS" ]; then
    echo "Error: Failed to download IP list or list is empty."
    exit 1
fi

echo "Generating MikroTik script..."

# Start with cleaning the existing list
echo "/ip firewall address-list remove [find list=\"${LIST_NAME}\"]" > "$OUTPUT_FILE"

# Use a loop to add addresses. 
# For performance in ROS 7, we can use a more compact format or just individual lines.
# Given the size (thousands of entries), individual lines are safer for 'import' stability.
echo "/ip firewall address-list" >> "$OUTPUT_FILE"
while read -r line; do
    if [[ ! -z "$line" && "$line" != "#"* ]]; then
        echo "add list=\"${LIST_NAME}\" address=$line comment=\"Imported by Gitea Action\"" >> "$OUTPUT_FILE"
    fi
done <<< "$IPS"

echo "Done. Script saved to ${OUTPUT_FILE}"
