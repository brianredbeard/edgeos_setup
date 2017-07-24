#!/usr/bin/env python
#    aws_vpnconfig.py - a utility to generate vyos VPN config stanzas from 
#      aws vpn configurations
#    Copyright (C) 2017 Brian 'redbeard' Harrington
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

from __future__ import print_function
from xml.etree import cElementTree as ElementTree
from pprint import pprint

import json
import boto3
import operator
import textwrap
import xml.etree.ElementTree as ET

try:
    import argparse
    arg = argparse.ArgumentParser(
    description='Generate vyOS/EdgeOS VPN configs for AWS')
    arg.add_argument('--tag-value', '-t', type=str, 
            help='Tag to sort for locations')
    arg.add_argument('--vti', '-i', type=int, default=0, 
            help='Beginning VTI interface to create')
    arg.add_argument('--skip-nat', action='store_false',
            help='Skip output of NAT configuation')
    arg.add_argument('--skip-ips', action='store_false',
            help='Skip output of IPSec ESP Group configuation')
    arg.add_argument('--skip-ike', action='store_false', 
            help='Skip output of IKE configuation')

    flags = arg.parse_args()
except ImportError:
    flags = None

def dict_from_xml(element_tree):
    """Traverse the given XML element tree to convert it into a dictionary.

    :param element_tree: An XML element tree
    :type element_tree: xml.etree.ElementTree
    :rtype: dict
    """
    def internal_iter(tree, accum):
        """Recursively iterate through the elements of the tree accumulating
        a dictionary result.

        :param tree: The XML element tree
        :type tree: xml.etree.ElementTree
        :param accum: Dictionary into which data is accumulated
        :type accum: dict
        :rtype: dict
        """
        if tree is None:
            return accum

        if tree.getchildren():
            accum[tree.tag] = {}
            for each in tree.getchildren():
                result = internal_iter(each, {})
                if each.tag in accum[tree.tag]:
                    if not isinstance(accum[tree.tag][each.tag], list):
                        accum[tree.tag][each.tag] = [
                            accum[tree.tag][each.tag]
                        ]
                    accum[tree.tag][each.tag].append(result[each.tag])
                else:
                    accum[tree.tag].update(result)
        else:
            accum[tree.tag] = tree.text

        return accum

    return internal_iter(element_tree, {})


# Ensure that VPN connections are not sent through NAT
natsetup = '''
    set vpn ipsec auto-firewall-nat-exclude enable'''

# Configure template for IKE configuration
ikesetup = '''
    set vpn ipsec ike-group {group_name} dead-peer-detection action restart
    set vpn ipsec ike-group {group_name} dead-peer-detection interval {dp_interval}
    set vpn ipsec ike-group {group_name} dead-peer-detection timeout {dp_time}
    set vpn ipsec ike-group {group_name} ikev2-reauth no
    set vpn ipsec ike-group {group_name} key-exchange ikev1
    set vpn ipsec ike-group {group_name} lifetime {ike_life}
    set vpn ipsec ike-group {group_name} proposal 1 dh-group {pfs_group}
    set vpn ipsec ike-group {group_name} proposal 1 encryption {enc}
    set vpn ipsec ike-group {group_name} proposal 1 hash {auth}'''

def ikeConfig(interface, gname):
  
    ips = interface

    life=ips['ike']['lifetime']
    auth=ips['ike']['authentication_protocol']
    dp_int=ips['ipsec']['dead_peer_detection']['interval']
    dp_timeout=int(ips['ipsec']['dead_peer_detection']['retries']) * int(dp_int)
    pfs_group=ips['ike']['perfect_forward_secrecy'].lstrip('group')
    encryption=ips['ike']['encryption_protocol']

    if encryption == 'aes-128-cbc':
        encryption = 'aes128'
    return(textwrap.dedent(ikesetup.format(group_name=gname, ike_life=life,
        pfs_group=pfs_group, auth=auth, enc=encryption, dp_interval=dp_int,
        dp_time=dp_timeout)))


# Ideally this would be perfectly configurable.  Unfortunately I have not been
# able to find documentation on the various _potential_ values that can return
# in a VPN configuation object.  As such, we abstract encryption slightly, and
# cannot dynamically determine perfect forward secrecy nor compression.
ipssetup = '''
    set vpn ipsec {protocol}-group {group_name} compression disable
    set vpn ipsec {protocol}-group {group_name} lifetime {ipsec_life}
    set vpn ipsec {protocol}-group {group_name} mode {mode}
    set vpn ipsec {protocol}-group {group_name} pfs enable
    set vpn ipsec {protocol}-group {group_name} proposal 1 encryption {enc}
    set vpn ipsec {protocol}-group {group_name} proposal 1 hash {auth}'''

def ipsConfig(interface, gname):
  
    ips = interface

    life=ips['ipsec']['lifetime']
    mode=ips['ipsec']['mode']
    auth=ips['ipsec']['authentication_protocol']
    if auth == 'hmac-sha1-96':
        auth='sha1'
    prot=ips['ipsec']['protocol']
    encryption=ips['ipsec']['encryption_protocol']

    if encryption == 'aes-128-cbc':
        encryption = 'aes128'
    return(textwrap.dedent(ipssetup.format(group_name=gname, ipsec_life=life,
        mode=mode, auth=auth, protocol=prot, enc=encryption)))



peerconfig = '''
    set vpn ipsec site-to-site peer {vpg_ip} authentication mode pre-shared-secret
    set vpn ipsec site-to-site peer {vpg_ip} authentication pre-shared-secret {psk}
    set vpn ipsec site-to-site peer {vpg_ip} connection-type initiate
    set vpn ipsec site-to-site peer {vpg_ip} description 'AWS {link_name}'
    set vpn ipsec site-to-site peer {vpg_ip} ike-group {ike_group}
    set vpn ipsec site-to-site peer {vpg_ip} ikev2-reauth inherit
    set vpn ipsec site-to-site peer {vpg_ip} local-address {egress_ip}
    set vpn ipsec site-to-site peer {vpg_ip} vti bind vti{inst}
    set vpn ipsec site-to-site peer {vpg_ip} vti esp-group {ips_group}'''

def peerConfig(interface, name, ike_group, ips_group, num=0):
    ips = interface
    vpg_ip=ips['vpn_gateway']['tunnel_outside_address']['ip_address']
    cgw_ip=ips['customer_gateway']['tunnel_outside_address']['ip_address']
    psk=ips['ike']['pre_shared_key']

    return(textwrap.dedent(peerconfig.format(vpg_ip=vpg_ip, psk=psk, 
        link_name=name, ike_group=ike_group, ips_group=ips_group, 
        egress_ip=cgw_ip, inst=num)))

vticonfig = '''
    set interfaces vti vti{inst} address {inside_ip}
    set interfaces vti vti{inst} description 'AWS {link_name}'
    set interfaces vti vti{inst} mtu {mtu}'''

def vtiConfig(interface, name, num=0):
    ipsec = interface
    cgw = ipsec['customer_gateway']
    inside = cgw['tunnel_inside_address']
    cgw_inside_ip = inside['ip_address'] + "/" + inside['network_cidr']
    #mtu=ipsec['ipsec']['tcp_mss_adjustment']
    mtu=1436
    return(textwrap.dedent(vticonfig.format(inst=num, link_name=name, 
        inside_ip=cgw_inside_ip, mtu=mtu)))


def staticRoutes(interface, routes):
    output = "\n"
    for route in routes:
        r = route
        iname = "vti" + str(interface)
        o = "set protocols static interface-route {cidr} next-hop-interface {i}"
        output = output + o.format(cidr=r, i=iname)
    return(output)

def main():

    # It's unlikely that we'll have different configs for ESP or IKE groups
    # but we'll make it so that we can plan for the potential case
    ei = 0
    ii = 0

    f = vars(flags)

    c = boto3.client('ec2')

    vpns = c.describe_vpn_connections()['VpnConnections']

    # A lot of these sections become boilerplate and for some users they will
    # not need it more than once

    if f['skip_nat']:
        print(textwrap.dedent(natsetup))
    # We will store the interface number in i (e.g. interface/index) 
    i = f['vti']

    for vpn in vpns:
        routes = []
        # Retrieve the corresponding details of the vpn gateway attached to
        # the connection.
        vgw = vpn['VpnGatewayId']
        vpgs = c.describe_vpn_gateways(VpnGatewayIds=[vgw])['VpnGateways'][0]

        # Extract the routes from the VPN Gateway config
        for attach in vpgs['VpcAttachments']:
            vpcid = attach['VpcId']
            vpc = c.describe_vpcs(VpcIds=[vpcid])['Vpcs'][0]
            routes.append(vpc['CidrBlock'])


        # Serialize the XML configuration of the connection into a python dict
        v = dict_from_xml(ET.fromstring(vpn['CustomerGatewayConfiguration']))
        tunnels = v['vpn_connection']

        for vconf in tunnels['ipsec_tunnel']:
            # iterate through the tags to find the name of the config
            for tag in vpn['Tags']:
                if tag['Key'] == "Name":
                    name = tag['Value']

            # Only operate on the value if there is a name tag
            if (f['tag_value'] is None) or \
                (f['tag_value'].upper() in name.upper()):
                gname = "aws-vpc"
                 
                # check if this is the first processed interface
                if i == f['vti']:
                    # Just in case we need to create multiple IKE/ESP configs
                    # we get ready for that name.
                    egname = gname
                    ips_def = ipsConfig(interface=vconf, gname=egname)
                    if f['skip_ips']:
                        print(ipsConfig(interface=vconf, gname=egname))
                else:
                    # if this config differs from the default, output it
                    if ips_def != ipsConfig(interface=vconf, gname=egname):
                        ei += 1
                        egname = gname + "-" + str(ei)
                        if f['skip_ips']:
                            print(ipsConfig(interface=vconf, gname=egname))
                        
                # check if this is the first processed interface
                if i == f['vti']:
                    # Same as above with making sure we could handle multiple
                    # IKE/ESP configs
                    igname = gname 
                    ike_def = ikeConfig(interface=vconf, gname=igname)
                    if f['skip_ike']:
                        print(ikeConfig(interface=vconf, gname=igname))
                else:
                    # if this config differs from the default, output it
                    if ike_def != ikeConfig(interface=vconf, gname=igname):
                        ii += 1
                        igname = gname + "-" + str(ii)
                        if f['skip_ike']:
                            print(ikeConfig(interface=vconf, gname=igname))

                # Output the vti interfaces
                print(vtiConfig(interface=vconf, name=name, num=i))

                # Output the site-to-stei configurations
                print(peerConfig(interface=vconf, name=name, ike_group=igname, 
                    ips_group=egname, num=i))

                # Print routes to the VPC(s)
                print(staticRoutes(interface=i, routes=routes))

                i+=1

if __name__ == '__main__':
    main()
