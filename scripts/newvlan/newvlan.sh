#!/bin/bash
###
#
# newvlan.sh - A utility to generate the commands for a new edgerouter VLAN
# Brian 'redbeard' Harrington - 2017-04-14
#
##

printhelp() {
	echo "${0} -v VLANID -n NETNAME -g GATEWAY"
	echo "  -v VLANID  - The numeric VLAN ID to assign"
	echo "  -n NETNAME - Friendly name to identify the network"
	echo "               (used with firewall, interface names, etc. no spaces)"
	echo "  -g GATEWAY - IP Address to assign on the edgerouter as the gateway"
	echo "               for this network in CIDR format"
	echo "  e.g. ${0} -n tvscreens -g 192.168.1.1/24"
}

while getopts "v:n:g:" OPTION
do
	case ${OPTION} in
		v)
			VLANID=${OPTARG}
			;;
		n)
			NAME=${OPTARG}
			;;
		g)
			GATEWAY=${OPTARG}
			;;
		*)
			printhelp
			exit
			;;
	esac
done

if [ -z ${NAME} ] || [ -z ${GATEWAY} ] || [ -z ${VLANID} ]; then
	echo "You must supply a NETNAME and GATEWAY"
	printhelp
	exit
fi

NAMEUPPER=`echo ${NAME} | tr A-z A-Z`
NAMELOWER=`echo ${NAME} | tr A-z a-z`

cat <<EOF
set interfaces bridge br${VLANID} address ${GATEWAY}
set interfaces bridge br${VLANID} aging 300
set interfaces bridge br${VLANID} bridged-conntrack disable
set interfaces bridge br${VLANID} description br.${NAMELOWER}
set interfaces bridge br${VLANID} firewall in name IPv4_IN_${NAMEUPPER}
set interfaces bridge br${VLANID} firewall local name IPv4_LOCAL_${NAMEUPPER}
set interfaces bridge br${VLANID} firewall out name IPv4_OUT_${NAMEUPPER}
set interfaces bridge br${VLANID} hello-time 2
set interfaces bridge br${VLANID} max-age 20
set interfaces bridge br${VLANID} priority 4096
set interfaces bridge br${VLANID} promiscuous disable
set interfaces bridge br${VLANID} stp true
set interfaces ethernet eth3 vif ${VLANID} bridge-group bridge br${VLANID}
set interfaces ethernet eth3 vif ${VLANID} description trunk.${NAMELOWER}
set service dns forwarding listen-on br${VLANID}
EOF
