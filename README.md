# EdgeOS Setup Scripts

## About

This repository is a set of scripts and other utilities to improve the overal
functioning of the Ubiquiti EdgeRouter series of devices.  These scripts are not
maintained by Ubiquiti and are provided with no warranty expressed or implied.

This repository does not replace a basic knowledge of how to navigate the EdgeOS
CLI.  For more information on getting started with EdgeOS, consult the User
Guide available at
[https://www.ubnt.com/download/edgemax](https://www.ubnt.com/download/edgemax)

Now, let's get down to bid'ness.

The Ubiquiti EdgeRouter series of devices (included in the EdgeMax line of
products) are Linux based routers with a number of features comparable to more
expensive networking gear.  With a proper understanding of how the devices work,
this functionality can far exceed hardware available at 10x the price.

## Structure

```
  Repo
  ├── Documentation - information on how the device operates
  ├── config_snippets - sets of configuration commands for various tasks
  ├── fs -  files to be added to the filesystem where "fs" becomes "/"
  │   └── config
  │       └── scripts
  │           └── post-config.d
  └── scripts - scripts for day to day management
```

## Usage

To use this repository clone and then deploy desired files as follows:

```
  $ scp -r fs router:
  $ sudo cp -Rv fs/* /
```

## Contents

 - `change_auth_loglevel.sh` - Fix some nits with logging on the device
 - `decrease_sshguard_attack.sh` - Change the configuration of `sshguard`
 - `install_packages.sh` - Persist additional packages across firmware upgrades

<!-- vim: ts=2 sw=2 expandtab tw=80 :
-->
