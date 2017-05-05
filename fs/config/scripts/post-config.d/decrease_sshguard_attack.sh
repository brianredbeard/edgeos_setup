#!/bin/sh

grep -q "\-a 40" /etc/default/sshguard

if [ "$?" -eq "0" ]; then
	sed -i '/ARGS/{s/-a 40/-a 30/}' /etc/default/sshguard
	/etc/init.d/sshguard restart
fi

exit 0
