#!/bin/bash
#Made by Mick Beer to detect new devices on the network.

# Set the time interval between scans (in seconds)
interval=3

# Loop infinitely, scanning the network at the specified interval
while true; do
  # Get the list of IP addresses on the network using arp-scan
  echo "Scanning for new devices on the network..."
  new_ips=$(sudo arp-scan --localnet --numeric --quiet --ignoredups | grep -E '([a-f0-9]{2}:){5}[a-f0-9]{2}' | awk '{print $1}')
  echo "Scan for new devices on the network completed."

  # Check if there are any new devices on the network
  if [ -n "$new_ips" ]; then
    echo "New devices found on the network: $new_ips"
    notify-send -u normal "New devices found on the network" "$new_ips"
  else
    echo "No new devices found on the network."
  fi

  # Wait for the specified interval
  echo "Waiting for $interval seconds..."
  sleep "$interval"
done
