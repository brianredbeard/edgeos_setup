#!/bin/bash

doneit='/var/lib/my_packages'
packages='sshguard rsync iftop iptraf mtr-tiny bmon'

if [ -e $doneit ]; then
exit 0;
fi

apt-get update
apt-get install -y $packages 
if [ $? == 0 ]; then 
 echo package install successful 
  touch $doneit 
else 
  echo package install failed 
fi 
exit 0
