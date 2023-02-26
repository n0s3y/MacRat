#!/bin/bash
# Made by Mick Beer to detect new devices on the network and scan them with Nmap and Shodan.

# Set the time interval between scans (in seconds)
interval=5

# Set the Shodan API key
SHODAN_API_KEY=""

# Set the output file location and name
output_file="/tmp/network_scan_$(date +%Y%m%d_%H%M%S).txt"

# Set the previous output file to an empty string
prev_file=""

# Loop infinitely, scanning the network at the specified interval
while true; do
  # Get the list of IP addresses on the network using arp-scan
  echo "Scanning for new devices on the network..."
  new_ips=$(sudo arp-scan --localnet --numeric --quiet --ignoredups | grep -E '([a-f0-9]{2}:){5}[a-f0-9]{2}' | awk '{print $1}')
  echo "Scan for new devices on the network completed."

  # Check if there are any new devices on the network
  if [ -n "$new_ips" ]; then
    echo "New devices found on the network: $new_ips"
    
    # Loop through the new IP addresses and scan them with Nmap and Shodan
    for ip_address in $new_ips; do
      # Scan the IP address with Nmap and save the output to the output file
      echo "Scanning $ip_address with Nmap..."
      nmap -vvv -sC -sV -Pn -A -p- "$ip_address" | tee -a "$output_file"
      echo "Scan of $ip_address with Nmap completed."

      # Scan the IP address with Shodan and save the output to a CSV file
      echo "Scanning $ip_address with Shodan..."
      shodan search "ip:$ip_address" --fields ip_str,port,transport,ssl,ciphers,protocols,vulns --separator , | tee -a "/tmp/shodan_scan_$(date +%Y%m%d_%H%M%S).csv"
      echo "Scan of $ip_address with Shodan completed."
    done

    # Compare the new output to the previous output
    if [ -n "$prev_file" ]; then
      echo "Comparing network scan results..."
      diff_output=$(diff "$output_file" "$prev_file" 2>/dev/null)

      # If the output has changed, show the difference and notify the user
      if [ "$diff_output" != "" ]; then
        echo "Network scan results have changed:"
        echo "$diff_output"
        notify-send -u critical "ALERT: Network scan results have changed" "Check the output file for more details" && paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga
      else
        echo "Network scan results have not changed."
      fi
    fi

    # Set the previous output file to the current output file
    prev_file="$output_file"
  else
    echo "No new devices found on the network."
  fi

  # Wait for the specified interval
  echo "Waiting for $interval seconds..."
  sleep "$interval"

  # Set the output file location and name for the next scan
  output_file="/tmp/network_scan_$(date +%Y%m%d_%H%M%S).txt"
done
