#!/bin/sh
# See LICENSE.
# Copyright (C) 2019 Akito <akito.kitsune@protonmail.com>
cd /var/etc/openvpn/ccd
julia ovpn_staticIP_giver.jl add $1