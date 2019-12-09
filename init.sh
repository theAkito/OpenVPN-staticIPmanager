#!/bin/sh
# See LICENSE.
# Copyright (C) 2019 Akito <akito.kitsune@protonmail.com>
mkdir /var/etc/openvpn/ccd && \
#touch /var/etc/openvpn/ccd/clients.cfg && \
curl -sSL https://raw.githubusercontent.com/Akito13/julia-serving-hookers/master/ovpn_adduser.sh \
  -o /ovpn_adduser.sh && \
curl -sSL https://raw.githubusercontent.com/Akito13/julia-serving-hookers/master/scripts/ovpn_staticIP_giver.jl \
  -o /var/etc/openvpn/ccd/ovpn_staticIP_giver.jl && \
cd /var/etc/openvpn/ccd/ && \
julia ovpn_staticIP_giver.jl init