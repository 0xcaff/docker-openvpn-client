docker-openvpn-client
=====================

> Complexity is the worst enemy of security.
>
> --- Bruce Schneier

A simple, minimal docker openvpn client. Before starting a VPN, it sets up a
restrictive outbound firewall which only allows traffic to a specified ip, port,
and protocol combination.

This image's goal is not to support every feature and configuration, but to show
how openvpn can be used with docker containers.

Usage
-----

The best way to use this container is with a `docker-compose.yml` file. Here's a
simple example:

```yaml
version: '3.4'

services:
  # This is the vpn service responsible for establishing a connection to the VPN
  # server and sending traffic to it.
  vpn:
    image: 0xcaff/openvpn-client

    # Extra permissions required for the image to function.
    cap_add:
      - net_admin
    devices:
      - /dev/net/tun

    # The ovpn configuration file must be present at the /vpn/config/config.ovpn
    # path.
    volumes:
      - ./config/:/vpn/config/

    # The only allowed traffic leaving this container is to the specified ip,
    # port, and protocol.
    environment:
      VPN_ALLOW_IP_ADDRESS: 178.60.78.125

  # This service utilizes the VPN connection using network_mode.
  vpn_consumer:
    image: jwilder/whoami

    # Share the network stack of the vpn client container. When this container
    # binds ports, they can be reached through the vpn service. This also adds
    # an implicit depnds_on for the vpn service.
    network_mode: service:vpn
```

For a full example which includes exposing and consuming `vpn_consumer` from other
containers, check out the [`./docker-compose.yml`][compose].

[compose]: ./docker-compose.yml
