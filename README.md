# MacRat
Detecting hosts on a network using arp-scan, nmap and shodan to identify, alert and analyse the hosts

##
A version of MacBasterd but without exploiting, only detecting CVE's and scanning hosts with nmap and shodan

###
To run this script as a cronjob in the background, you can add the following line to your crontab file (crontab -e):

```
* * * * * /path/to/network_monitor.sh >/dev/null 2>&1 &
```
