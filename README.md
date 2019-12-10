## Static IP Manager for OpenVPN

This project aims to provide a service that manages the assignment and removal of static IPs for [OpenVPN](https://openvpn.net/) servers wishing their clients to always be connected with the same IP.

At this moment, this project is in alpha state and only does rudimentary assignment, that is acceptable for up to a couple of hundred clients and IPs. A CIDR range of 10.128.0.0/16 is also currently hard coded into the service, because of personal use cases.

It is planned to make this project more open, configurable and much better in the future, to make it accessible to a larger audience than it's current but urgent use case has.
Finally, this shall be the back-end for an [OPNsense](https://opnsense.org/) front-end plugin, to ease the usage as much as possible.

## To Do
* Add multiple options possibility to config file
* Add CIDR range to config file
* Add option to remove IP assignment
* Add help text
* ~~Add IP assignment~~
* ~~Add config-client-dir location to config file~~  