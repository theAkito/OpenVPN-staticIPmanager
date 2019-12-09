#!/bin/sh
# See LICENSE.
# Copyright (C) 2019 Akito <akito.kitsune@protonmail.com>
cd /root && \
curl -sSL https://julialang-s3.julialang.org/bin/freebsd/x64/1.3/julia-1.3.0-freebsd-x86_64.tar.gz \
  -o julia-1.3.0-freebsd-x86_64.tar.gz && \
tar zxf julia-1.3.0-freebsd-x86_64.tar.gz && \
rm julia-1.3.0-freebsd-x86_64.tar.gz && \
ln -s /root/julia-1.3.0/bin/julia /usr/bin/julia && \
mkdir /var/etc/openvpn/ccd && \
#touch /var/etc/openvpn/ccd/clients.cfg && \
curl -sSL https://raw.githubusercontent.com/Akito13/julia-serving-hookers/master/ovpn_adduser.sh \
  -o /ovpn_adduser.sh && \
curl -sSL https://raw.githubusercontent.com/Akito13/julia-serving-hookers/master/scripts/ovpn_staticIP_giver.jl \
  -o /var/etc/openvpn/ccd/ovpn_staticIP_giver.jl && \
cd /var/etc/openvpn/ccd/ && \
julia ovpn_staticIP_giver.jl init