#!/bin/bash
set -eu
set -o pipefail

LANG=C

IFACE=wg0

echo "Tunables:"

for i in /proc/sys/net/ipv4/{icmp_echo_ignore_all,icmp_echo_ignore_broadcasts,icmp_msgs_burst,icmp_msgs_per_sec,icmp_ratelimit,ping_group_range,ip_forward}
do
  echo -e "$i\t = $(cat $i)"
done

echo ""
echo "Interface tunables:"

for i in /proc/sys/net/ipv4/conf/$IFACE/{forwarding,rp_filter}
do
  echo -e "$i\t = $(cat $i)"
done

echo ""
echo "Address:"
ip address show $IFACE

echo ""
echo "Link:"
ip link show $IFACE

echo ""
echo "Routes:"

ip route list dev $IFACE

while IFS=$'\t' read -r iface dest gw flags refcount use metric mask mtu window rtt;
do

  if [[ "$iface" != "$IFACE" ]]; then
    continue
  fi
  
  echo -e "$iface\t$dest/$mask via $gw f:$flags metric:$metric mtu:$mtu"
done < /proc/net/route

echo ""
echo "Modules:"
while IFS=' ' read -r kname ksize kcount kdeps klive khex;
do
  declare found=false

  if [[ "$kname" = "usbip_core" ]]; then
    found=true
  fi

  if [[ "$kname" = "usbip_host" ]]; then
    found=true
  fi
  
  if [ "$found" = false ]; then
    continue
  fi
  
  echo -e "$klive\t$kname\t($kdeps)"
done < /proc/modules

echo ""
echo "systemd: usbipd daemon active:"
systemctl is-active usbipd

echo ""
echo "usbip TCP port 3240 listening:"
ss --numeric --tcp --listening src :3240

