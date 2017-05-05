#!/bin/sh


RESTART="false"

###
#  Change the basic confguration options for sshguard
#  For more info consult the sshguard man page on google
#  of the current sshguard version
###
grep -q  'ARGS=".*\-a 40' /etc/default/sshguard 

if [ "$?" -eq "0" ]; then
    sed -i '/ARGS/{s/-a 40/-a 30/}' /etc/default/sshguard
    RESTART="true"
fi

###
#  Change sshguard whitelist location
#  For more info consult the sshguard man page on google
#  of the current sshguard version
###
grep -q  'WHITELIST="/etc/sshguard/whitelist"' /etc/default/sshguard

if [ "$?" -eq "0" ]; then
    sed -i '/WHITELIST=/{s/WHITELIST=.*/WHITELIST="\/config\/user-data\/sshguard\/sshguard-whitelist"/}' /etc/default/sshguard
    RESTART="true"
fi

###
#  Enable sshguard blacklisting
#  For more info consult the sshguard man page on google
#  of the current sshguard version
###
grep -q  'ARGS=".*\-b' /etc/default/sshguard

if [ "$?" -eq "1" ]; then
    sed -i '/ARGS/{s/"$/ -b 120:\/config\/user-data\/sshguard\/sshguard-blacklist.db"/}' /etc/default/sshguard
    RESTART="true"
fi

###
#  The 1.8.x EdgeOS version changed the file auth.log facility in a way which
#  broke sshguard, this changes the facility back
###
grep -q authpriv\.notice  /etc/rsyslog.conf

if [ "$?" -eq "0" ]; then
    sed -i 's/authpriv.notice/authpriv\.*/g'   /etc/rsyslog.conf
    RESTART="true"
fi


if [ "${RESTART}" == "true" ]; then
    /etc/init.d/sshguard restart
fi

exit 0

# vim: ts=4 sw=4 expandtab :
