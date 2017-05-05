# Configuration Best Practices

## Showing the configuration
There are two schools of thought when it comes to configuration of EdgeRouter
devices.  When going to the forums, they will want you to post your
configuration in a very visually appealing manner (effectively the output of
`show configuration` inside of a <PRE> block.)

For the purposes of duplicating configurations over time, users will generally
find the output of `show configuration commands` much more useful.  This
provides a configuration output that is both easily processed through `grep`
when trying to identify sections as well as something that is easily processed
using the command `source` on the CLI or even via copy/paste.


`show configuration` output":

```
...
interfaces {
    ethernet eth0 {
        address dhcp
        dhcpv6-pd {
            no-dns
            pd 0 {
                interface switch0 {
                    host-address ::1
                    no-dns
                    prefix-id :0
                    service slaac
                }
                prefix-length /60
            }
            rapid-commit enable
        }
        duplex auto
        speed auto
    }
    ethernet eth1 {
        duplex auto
        speed auto
    }
    ethernet eth2 {
        duplex auto
        speed auto
    }
    ethernet eth3 {
        duplex auto
        speed auto
    }
    ethernet eth4 {
        duplex auto
        speed auto
    }
    loopback lo {
    }
    switch switch0 {
        address 10.0.0.1/24
        ipv6 {
            dup-addr-detect-transmits 1
            router-advert {
                cur-hop-limit 64
                link-mtu 0
                managed-flag false
                max-interval 600
                other-config-flag false
                prefix ::/64 {
                    autonomous-flag true
                    on-link-flag true
                    valid-lifetime 2592000
                }
                reachable-time 0
                retrans-timer 0
                send-advert true
            }
        }
        mtu 1500
        switch-port {
            interface eth1 {
            }
            interface eth2 {
            }
            interface eth3 {
            }
            interface eth4 {
            }
            vlan-aware disable
        }
    }
}
...
```

`show configuration commands` output:

```
set interfaces ethernet eth0 address dhcp
set interfaces ethernet eth0 dhcpv6-pd no-dns
set interfaces ethernet eth0 dhcpv6-pd pd 0 interface switch0 host-address '::1'
set interfaces ethernet eth0 dhcpv6-pd pd 0 interface switch0 no-dns
set interfaces ethernet eth0 dhcpv6-pd pd 0 interface switch0 prefix-id ':0'
set interfaces ethernet eth0 dhcpv6-pd pd 0 interface switch0 service slaac
set interfaces ethernet eth0 dhcpv6-pd pd 0 prefix-length /60
set interfaces ethernet eth0 dhcpv6-pd rapid-commit enable
set interfaces ethernet eth0 duplex auto
set interfaces ethernet eth0 speed auto
set interfaces ethernet eth1 duplex auto
set interfaces ethernet eth1 speed auto
set interfaces ethernet eth2 duplex auto
set interfaces ethernet eth2 speed auto
set interfaces ethernet eth3 duplex auto
set interfaces ethernet eth3 speed auto
set interfaces ethernet eth4 duplex auto
set interfaces ethernet eth4 speed auto
set interfaces loopback lo
set interfaces switch switch0 address 10.0.0.1/24
set interfaces switch switch0 ipv6 dup-addr-detect-transmits 1
set interfaces switch switch0 ipv6 router-advert cur-hop-limit 64
set interfaces switch switch0 ipv6 router-advert link-mtu 0
set interfaces switch switch0 ipv6 router-advert managed-flag false
set interfaces switch switch0 ipv6 router-advert max-interval 600
set interfaces switch switch0 ipv6 router-advert other-config-flag false
set interfaces switch switch0 ipv6 router-advert prefix '::/64' autonomous-flag true
set interfaces switch switch0 ipv6 router-advert prefix '::/64' on-link-flag true
set interfaces switch switch0 ipv6 router-advert prefix '::/64' valid-lifetime 2592000
set interfaces switch switch0 ipv6 router-advert reachable-time 0
set interfaces switch switch0 ipv6 router-advert retrans-timer 0
set interfaces switch switch0 ipv6 router-advert send-advert true
set interfaces switch switch0 mtu 1500
set interfaces switch switch0 switch-port interface eth1
set interfaces switch switch0 switch-port interface eth2
set interfaces switch switch0 switch-port interface eth3
set interfaces switch switch0 switch-port interface eth4
set interfaces switch switch0 switch-port vlan-aware disable
```

## Backing up the configuration

As you saw from the above, saving the configuration for later use can often be
as simple as running `show configuration commands`.  

Despite how it may seem, when you are on the CLI interface of an EdgeOS device,
you are in a full Bash shell (It is actually Bash with an wrapper called `vbash`
around it providing the "Cisco-like" interface which is a part of VyOS).  This
means your traditional `POSIX` mechanisms for manipulating input/output apply.
Thus... let's make this simple:

```
$ show configuration commands > ~/Config-`date +%Y-%m-%d.%H:%M:%S`.txt
```

This will save a dump of all of those commands to a file of the form
`Config-2017-05-05.13:15:20.txt`.  

## Applying the configuration

The simplest ways of applying the configuration are to go into the
"configuration" mode and perform one of the following:

  1. Copy/paste the commands you need.

  2. Use `source` - e.g:

```
ubnt@router# source Config-2017-05-05.13:15:20.txt
```

<!-- vim: ts=2 sw=2 expandtab tw=80 :
-->
