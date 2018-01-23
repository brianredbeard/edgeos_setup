# Other Explorations with Ubiquiti Hardware

## About

This is a dumping ground for random notes in exploring other Ubiquiti hardware.


## Hardware Platforms

### UniFi switch

This work has been verified on a number of Ubiquiti hardware switches including
the UniFi switch PoE 500w & 750w models.

#### System Information

##### CPU

```
US.v3.7.55# cat /proc/cpuinfo
Processor	: ARMv7 Processor rev 1 (v7l)
processor	: 0
BogoMIPS	: 795.44

Features	: swp half thumb fastmult edsp tls
CPU implementer	: 0x41
CPU architecture: 7
CPU variant	: 0x4
CPU part	: 0xc09
CPU revision	: 1

Hardware	: Broadcom iProc
Revision	: 0000
Serial		: 0000000000000000
```

##### Components

The UniFi switch hardware is running a minimal embedded Linux distro.  As of
firmware `3.7.55.6308` it us using the following:

| Component | Software | Version |
| :--       | :--      | :--     |
| Kernel    | Linux    | 3.6.5   |
| LibC      | µLibC    | 0.9.33.2 |
| Init      |          |         |
| sshd      | dropbear | v2016.74 |
|           | busybox  | 1.19.4  |


##### Filesystem exploration

This is a list of the binaries in `/bin` with the exlusion of busybox (noted
below) and dropbear:

```
US.v3.7.55# ls -lS /bin/ | grep -v -e busybox -e dropbear
-rwxr-xr-x    1 admin    admin     37815280 Apr 13 16:11 switchdrvr
-rwxr-xr-x    1 admin    admin      1774709 Apr 13 16:06 ubntbox
-rwxr-xr-x    1 admin    admin       513428 Apr 13 15:58 tcpdump
-rwxr-xr-x    1 admin    admin       511626 Apr 13 16:06 mcad
-rwxr-xr-x    1 admin    admin       253387 Apr 13 15:57 ip
-rwxr-xr-x    1 admin    admin       239898 Apr 13 15:57 jq
-rwxr-xr-x    1 admin    admin       212639 Apr 13 16:00 wget
-rwxr-xr-x    1 admin    admin       147890 Apr 13 16:11 procmgr
-rwxr-xr-x    1 admin    admin       139369 Apr 13 16:02 syncdb
-rwxr-xr-x    1 admin    admin        73177 Apr 13 16:02 syncdb_test
-rwxr-xr-x    1 admin    admin        21013 Apr 13 15:56 hotplug2
-rwxr-xr-x    1 admin    admin        20904 Apr 13 15:56 ntpclient
-rwxr-xr-x    1 admin    admin        16871 Apr 13 15:57 udevtrigger
-rwxr-xr-x    1 admin    admin        14481 Apr 13 15:59 fw_printenv
-rwxr-xr-x    1 admin    admin        13512 Apr 13 15:56 mtd
-rwxr-xr-x    1 admin    admin        11384 Apr 13 16:11 proctest
-rwxr-xr-x    1 admin    admin        10139 Apr 13 16:11 procutil
-rwxr-xr-x    1 admin    admin         5991 Jan  5 10:15 htb
-rwxr-xr-x    1 admin    admin         3986 Jan  5 10:15 qosLinkAddGroup.sh
-rwxr-xr-x    1 admin    admin         3542 Apr 13 15:56 adjtimex
-rwxr-xr-x    1 admin    admin         2493 Jan  5 10:15 walled_action.sh
-rwxr-xr-x    1 admin    admin         1828 Jan  5 10:15 qosLinkInit.sh
-rwxr-xr-x    1 admin    admin         1745 Apr 13 16:06 mca-custom-alert.sh
-rwxr-xr-x    1 admin    admin         1583 Jan  5 10:15 pktgen.sh
-rw-r--r--    1 admin    admin         1573 Jan  5 10:15 support
-rwxr-xr-x    1 admin    admin         1180 Jan  5 10:15 qosLinkAddVap.sh
-rwxr-xr-x    1 admin    admin          835 Apr 13 16:06 mca.sh
-rwxr-xr-x    1 admin    admin          686 Apr 13 16:06 fwupdate
-rwxr-xr-x    1 admin    admin          666 Apr 13 15:56 rate.awk
-rwxr-xr-x    1 admin    admin          269 Jan  5 10:15 show_node
-rwxr-xr-x    1 admin    admin          205 Jan  5 10:15 show_nt
-rwxr-xr-x    1 admin    admin          145 Jan  5 10:15 syslogd_wrapper.sh
-rwxr-xr-x    1 admin    admin           69 Jan  5 10:15 radartoolw
lrwxrwxrwx    1 admin    admin           24 Apr 13 16:12 syswrapper.sh -> ../usr/etc/syswrapper.sh
lrwxrwxrwx    1 admin    admin            8 Apr 13 16:12 devshell -> procutil
lrwxrwxrwx    1 admin    admin            8 Apr 13 16:12 mem -> procutil
lrwxrwxrwx    1 admin    admin            8 Apr 13 16:12 pm -> procutil
lrwxrwxrwx    1 admin    admin            8 Apr 13 16:12 stack-trace -> procutil
lrwxrwxrwx    1 admin    admin            7 Apr 13 16:12 cfgmtd -> ubntbox
lrwxrwxrwx    1 admin    admin            7 Apr 13 16:12 factorytest -> ubntbox
lrwxrwxrwx    1 admin    admin            7 Apr 13 16:12 fwupdate.real -> ubntbox
lrwxrwxrwx    1 admin    admin            7 Apr 13 16:12 swctrl -> ubntbox
lrwxrwxrwx    1 admin    admin            7 Apr 13 16:12 ubntconf -> ubntbox
lrwxrwxrwx    1 admin    admin            7 Apr 13 16:12 utermd -> ubntbox
lrwxrwxrwx    1 admin    admin            6 Apr 13 16:12 mca-dump -> mca.sh
lrwxrwxrwx    1 admin    admin            6 Apr 13 16:12 mca-sta -> mca.sh
lrwxrwxrwx    1 admin    admin            4 Apr 13 16:12 mca-cli -> mcad
lrwxrwxrwx    1 admin    admin            4 Apr 13 16:12 mca-cli-op -> mcad
lrwxrwxrwx    1 admin    admin            4 Apr 13 16:12 mca-ctrl -> mcad
lrwxrwxrwx    1 admin    admin            4 Apr 13 16:12 mca-monitor -> mcad
lrwxrwxrwx    1 admin    admin            4 Apr 13 16:12 redirector -> mcad
lrwxrwxrwx    1 admin    admin            4 Apr 13 16:12 reset-handler -> mcad
lrwxrwxrwx    1 admin    admin            4 Apr 13 16:12 uplink-monitor -> mcad

```

It is interesting to note the following:

  - The presence of the binary `ubntbox` providing a number of different
    functions.
  - The presence of `switchdrvr` which is generally associate with Broadcom
    fastpath devices.
  - For all of the attempts at minimalization, they're still stuffing `jq` into
    the image.  ;)
  - Lots of these utilities are shell scripts.

Making some assumptions about `switchdrvr` we should dig in further.

```
US.v3.7.55# find / -iname "*fast*"
/proc/sys/net/ipv4/tcp_fastopen
/var/run/fastpath
/sys/module/tcp_cubic/parameters/fast_convergence
```

So it seems that indeed we do have fastpath available.  This also implies the
presence of the Broadcom proprietary kernel module.  Knowing that the CPU was
manufactured by Broadcom plus fastpath being used, this is almost a given.

```
US.v3.7.55# lsmod
Module                  Size  Used by    Tainted: P
linux_user_bde        102257  0
linux_kernel_bde      118746  1 linux_user_bde
gpiodev                 7193  0
ubnthal               239404  1 linux_kernel_bde
```

A quick google search of some of these modules confirms that linux_user_bde is a
part of Broadcom's [OpenFlow Data Plane Abstraction][of-dpa] kit.  This is often
used with systems implementing Broadcom's mercant silicon (often the Trident &
Trident II chipsets) with Linux.

In fact, all of those modules listed seem to provide a proprietary taint on the
kernel:

```
US.v3.7.55# find /sys/module/*/taint -exec grep -H P {} \;
/sys/module/gpiodev/taint:PO
/sys/module/linux_kernel_bde/taint:PO
/sys/module/linux_user_bde/taint:PO
/sys/module/ubnthal/taint:PO
```

#### ubntbox

The UniFi system seems to use a binary written by Ubiquiti similar to busybox
in it's mechanism.  It appears to determine the `${0}` used for it's execution
to determine it's function:

```
US.v3.7.55# ls -l /bin/ | grep ubntbox
lrwxrwxrwx    1 admin    admin            7 Apr 13 16:12 cfgmtd -> ubntbox
lrwxrwxrwx    1 admin    admin            7 Apr 13 16:12 factorytest -> ubntbox
lrwxrwxrwx    1 admin    admin            7 Apr 13 16:12 fwupdate.real -> ubntbox
lrwxrwxrwx    1 admin    admin            7 Apr 13 16:12 swctrl -> ubntbox
-rwxr-xr-x    1 admin    admin      1774709 Apr 13 16:06 ubntbox
lrwxrwxrwx    1 admin    admin            7 Apr 13 16:12 ubntconf -> ubntbox
lrwxrwxrwx    1 admin    admin            7 Apr 13 16:12 utermd -> ubntbox

```



#### Busybox Components

As to not pollute the list above, the following utilities are linked against
busybox:

| Component | Software | Version |
| :--       | :--      | :--     |
| [            | busybox | 1.19.4|
| [[           | busybox | 1.19.4|
| arp          | busybox | 1.19.4|
| arping       | busybox | 1.19.4|
| ash          | busybox | 1.19.4|
| awk          | busybox | 1.19.4|
| basename     | busybox | 1.19.4|
| brctl        | busybox | 1.19.4|
| bunzip2      | busybox | 1.19.4|
| busybox      | busybox | 1.19.4|
| bzcat        | busybox | 1.19.4|
| bzip2        | busybox | 1.19.4|
| cat          | busybox | 1.19.4|
| chgrp        | busybox | 1.19.4|
| chmod        | busybox | 1.19.4|
| chown        | busybox | 1.19.4|
| chroot       | busybox | 1.19.4|
| clear        | busybox | 1.19.4|
| cmp          | busybox | 1.19.4|
| cp           | busybox | 1.19.4|
| crond        | busybox | 1.19.4|
| crontab      | busybox | 1.19.4|
| cut          | busybox | 1.19.4|
| date         | busybox | 1.19.4|
| dd           | busybox | 1.19.4|
| df           | busybox | 1.19.4|
| diff         | busybox | 1.19.4|
| dirname      | busybox | 1.19.4|
| dmesg        | busybox | 1.19.4|
| du           | busybox | 1.19.4|
| echo         | busybox | 1.19.4|
| egrep        | busybox | 1.19.4|
| env          | busybox | 1.19.4|
| expr         | busybox | 1.19.4|
| false        | busybox | 1.19.4|
| fgrep        | busybox | 1.19.4|
| find         | busybox | 1.19.4|
| free         | busybox | 1.19.4|
| fsync        | busybox | 1.19.4|
| fuser        | busybox | 1.19.4|
| getty        | busybox | 1.19.4|
| grep         | busybox | 1.19.4|
| gunzip       | busybox | 1.19.4|
| gzip         | busybox | 1.19.4|
| halt         | busybox | 1.19.4|
| head         | busybox | 1.19.4|
| hexdump      | busybox | 1.19.4|
| hostid       | busybox | 1.19.4|
| hwclock      | busybox | 1.19.4|
| id           | busybox | 1.19.4|
| ifconfig     | busybox | 1.19.4|
| init         | busybox | 1.19.4|
| insmod       | busybox | 1.19.4|
| iostat       | busybox | 1.19.4|
| kill         | busybox | 1.19.4|
| killall      | busybox | 1.19.4|
| killall5     | busybox | 1.19.4|
| klogd        | busybox | 1.19.4|
| less         | busybox | 1.19.4|
| ln           | busybox | 1.19.4|
| lock         | busybox | 1.19.4|
| logger       | busybox | 1.19.4|
| login        | busybox | 1.19.4|
| ls           | busybox | 1.19.4|
| lsmod        | busybox | 1.19.4|
| lzcat        | busybox | 1.19.4|
| md5sum       | busybox | 1.19.4|
| mkdir        | busybox | 1.19.4|
| mkfifo       | busybox | 1.19.4|
| mknod        | busybox | 1.19.4|
| mktemp       | busybox | 1.19.4|
| mount        | busybox | 1.19.4|
| mpstat       | busybox | 1.19.4|
| mv           | busybox | 1.19.4|
| nc           | busybox | 1.19.4|
| netmsg       | busybox | 1.19.4|
| netstat      | busybox | 1.19.4|
| nice         | busybox | 1.19.4|
| nohup        | busybox | 1.19.4|
| nslookup     | busybox | 1.19.4|
| ntpd         | busybox | 1.19.4|
| passwd       | busybox | 1.19.4|
| pgrep        | busybox | 1.19.4|
| pidof        | busybox | 1.19.4|
| ping         | busybox | 1.19.4|
| ping6        | busybox | 1.19.4|
| pivot_root   | busybox | 1.19.4|
| pkill        | busybox | 1.19.4|
| poweroff     | busybox | 1.19.4|
| printf       | busybox | 1.19.4|
| ps           | busybox | 1.19.4|
| pstree       | busybox | 1.19.4|
| pwd          | busybox | 1.19.4|
| rdate        | busybox | 1.19.4|
| readlink     | busybox | 1.19.4|
| reboot       | busybox | 1.19.4|
| reset        | busybox | 1.19.4|
| rm           | busybox | 1.19.4|
| rmdir        | busybox | 1.19.4|
| rmmod        | busybox | 1.19.4|
| route        | busybox | 1.19.4|
| sed          | busybox | 1.19.4|
| seq          | busybox | 1.19.4|
| sh           | busybox | 1.19.4|
| sleep        | busybox | 1.19.4|
| sort         | busybox | 1.19.4|
| start-stop-daemon | busybox | 1.19.4|
| strings      | busybox | 1.19.4|
| stty         | busybox | 1.19.4|
| swapoff      | busybox | 1.19.4|
| swapon       | busybox | 1.19.4|
| switch_root  | busybox | 1.19.4|
| sync         | busybox | 1.19.4|
| sysctl       | busybox | 1.19.4|
| syslogd      | busybox | 1.19.4|
| tail         | busybox | 1.19.4|
| tar          | busybox | 1.19.4|
| tee          | busybox | 1.19.4|
| telnet       | busybox | 1.19.4|
| telnetd      | busybox | 1.19.4|
| test         | busybox | 1.19.4|
| tftp         | busybox | 1.19.4|
| time         | busybox | 1.19.4|
| top          | busybox | 1.19.4|
| touch        | busybox | 1.19.4|
| tr           | busybox | 1.19.4|
| traceroute   | busybox | 1.19.4|
| true         | busybox | 1.19.4|
| udhcpc       | busybox | 1.19.4|
| umount       | busybox | 1.19.4|
| uname        | busybox | 1.19.4|
| uniq         | busybox | 1.19.4|
| unlzma       | busybox | 1.19.4|
| unxz         | busybox | 1.19.4|
| uptime       | busybox | 1.19.4|
| vconfig      | busybox | 1.19.4|
| vi           | busybox | 1.19.4|
| watch        | busybox | 1.19.4|
| watchdog     | busybox | 1.19.4|
| wc           | busybox | 1.19.4|
| which        | busybox | 1.19.4|
| xargs        | busybox | 1.19.4|
| xzcat        | busybox | 1.19.4|
| yes          | busybox | 1.19.4|
| zcat         | busybox | 1.19.4|


[of-dpa]: https://github.com/Broadcom-Switch/of-dpa

<!--
vim: ts=2 sw=2 sts=2 et tw=80 :
-->
