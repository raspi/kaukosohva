#!/bin/bash
set -eu
set -o pipefail
#set -x

if [[ ! -f "wg.sender.private.key" ]]; then
  wg genkey | tee wg.sender.private.key | wg pubkey > wg.sender.pub.key
fi

if [[ ! -f "wg.receiver.private.key" ]]; then
  wg genkey | tee wg.receiver.private.key | wg pubkey > wg.receiver.pub.key
fi

if ip link show dev sender0 2> /dev/null; then
  ip link delete dev sender0
fi

if ip link show dev receiver0 2> /dev/null; then
  ip link delete dev receiver0
fi


# Sender
ip link add dev sender0 type wireguard
ip address add dev sender0 10.255.255.1/24
ip link set multicast on allmulticast on up dev sender0
ip route add multicast 224.0.0.0/24 dev sender0 scope link

wg set sender0 listen-port 56000 private-key wg.sender.private.key
wg set sender0 peer $(cat wg.receiver.pub.key) allowed-ips 10.255.255.0/24,224.0.0.0/24 persistent-keepalive 10 


# Receiver   
ip link add dev receiver0 type wireguard
ip address add dev receiver0 10.255.255.2/24
ip link set multicast on allmulticast on up dev receiver0
#ip route add multicast 224.0.0.0/24 dev receiver0 scope link

wg set receiver0 private-key wg.receiver.private.key 
wg set receiver0 peer $(cat wg.sender.pub.key) allowed-ips 10.255.255.0/24,224.0.0.0/24 endpoint 10.255.255.1:56000 persistent-keepalive 10

# Show settings   
ip address show dev receiver0
ip route show dev receiver0
ip address show dev sender0
ip route show dev sender0

echo ""

wg

echo ""
echo "Now run:"
echo ""
echo "sender.sh -I sender0 -w <window id>"
echo "receiver.sh -I receiver0"

echo ""
read -n 1 -s -r -p "Press any key to stop sender & receiver VPN"

ip link delete dev receiver0
ip link delete dev sender0

