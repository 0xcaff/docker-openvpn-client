#!/bin/sh

# This scripts:
# * Sets up a restrictive outbound ipv4 firewall only allowing traffic to one
#   destination (address, protocol, port, ip address). It is only a ipv4
#   firewall because docker (17.10.0-ce) only supports ipv6 behind a flag.
# * Starts OpenVPN

# Exit on first non-zero exit code like a sane language.
set -e

# A helper function to make something which stands out from the rest of the
# logs.
banner() {
  printf "\n-------- $1\n"
}

banner "Initializing Firewall"

# The local address range routed by the eth0 interface.
docker_network=$(ip -o addr show dev eth0 | awk '$3 == "inet" {print $4}')

# Clear output table.
iptables --flush OUTPUT

# Drop unmatched traffic.
iptables --policy OUTPUT DROP

# Allows traffic corresponding to inbound traffic.
iptables \
  --append OUTPUT \
  --match conntrack \
  --ctstate ESTABLISHED,RELATED \
  --jump ACCEPT

# Accept traffic to the loopback interface.
iptables \
  --append OUTPUT \
  --out-interface lo \
  --jump ACCEPT

# Accept traffic to tunnel interfaces.
iptables \
  --append OUTPUT \
  --out-interface tap0 \
  --jump ACCEPT

iptables \
  --append OUTPUT \
  --out-interface tun0 \
  --jump ACCEPT

# Accept traffic to vpn server.
iptables \
  --append OUTPUT \
  --destination "${VPN_ALLOW_IP_ADDRESS}" \
  --protocol "${VPN_ALLOWED_PROTO}" \
  --dport "${VPN_ALLOWED_PORT}" \
  --jump ACCEPT

# Accept local traffic to docker network. It doesn't seem possible to use the
# --realm flag in this iptables.
iptables \
  --append OUTPUT \
  --destination ${docker_network} \
  --jump ACCEPT

banner "Firewall Initialized"

banner "Launching OpenVPN"
openvpn --config /vpn/config/config.ovpn
