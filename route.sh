#!/bin/bash
echo "1" >/proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISH -j ACCEPT
@reboot    root    bash  route.sh
