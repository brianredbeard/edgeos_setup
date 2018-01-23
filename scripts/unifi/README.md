# UniFi utilities

## About
Ancillary utilities related to the management of UniFi endpoints.  These do not
replace the use of the UniFI control software, but augment and allow for
breakfix repair of certain situations.

## Scripts

  - `unfi_fab.py` - A library of functions to perform common operations executed
    via SSH with fabric against UniFi managed endpoints.

## Examples
  - `fab -f unifi_fabric.py   -H
    10.7.0.25,10.7.0.26,10.7.0.106,10.7.0.108,10.7.0.216,10.7.0.191,10.7.0.171,10.7.0.160,10.7.0.105,10.7.0.123,10.7.0.109,10.7.0.166,10.7.0.100,10.7.0.188,10.7.0.145
    set_inform:url='http://unifi.example.com:8080/inform'`

<!--
vim: set ts=2 sw=2 tw=80 expandtab :
-->
