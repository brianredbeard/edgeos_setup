#!/usr/bin/env python
from __future__ import with_statement
from __future__ import print_function
from fabric.api import *
from fabric.contrib.console import confirm
from fabric.network import disconnect_all
import requests

env.user = 'admin'
env.shell = "/bin/sh -l -c"
env.no_keys = True


def set_inform(url='http://unifi:8080/inform'):
    inform = "set-inform %s" % (url)
    run(inform)

def info():
    run('info')

def dump_config():
    run('cat cfg/mgmt')

def main():
    check_unifi_status()
    disconnect_all()

if __name__ == "__main__":
    main()

