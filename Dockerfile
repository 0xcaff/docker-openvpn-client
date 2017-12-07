FROM alpine:3.7

# Install runtime dependencies. The versions are pinned for reproducible,
# deterministic, pure builds.
RUN apk --update add \
  curl=7.57.0-r0 \
  iptables=1.6.1-r1 \
  ip6tables=1.6.1-r1 \
  openvpn=2.4.4-r1

# Log the public ip address of the container in every minute.
HEALTHCHECK --interval=60s --timeout=15s --start-period=120s \
  CMD curl 'https://api.ipify.org'

# This is where the configuration files will go.
VOLUME [ "/vpn/config" ]

# This is only address, port and protocol traffic will be allowed to be sent to
# (besides the docker internal network).
ENV VPN_ALLOW_IP_ADDRESS 9.9.9.9
ENV VPN_ALLOWED_PORT 1194
ENV VPN_ALLOWED_PROTO udp

# Some bootstrap (setting up the firewall), can only be done at container start
# time.
COPY ./setup_connection.sh /vpn/

ENTRYPOINT [ "/vpn/setup_connection.sh" ]
