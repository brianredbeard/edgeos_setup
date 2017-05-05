#!/bin/sh

grep -q authpriv\.notice  /etc/rsyslog.conf 

if [ "$?" -eq "0" ]; then
	sed -i 's/authpriv.notice/authpriv\.*/g'   /etc/rsyslog.conf
	
	cat <<-EOF> /etc/rsyslog.d/drop-vtysh.pl.conf
	:msg, contains, "COMMAND=/usr/bin/vtysh.pl -c show ip route summary json" ~
	:msg, contains, "pam_unix(sudo:session): session opened for user root by (uid=0)" ~
	:msg, contains, "pam_unix(sudo:session): session closed for user root" ~
EOF
	/etc/init.d/rsyslog restart
fi

exit 0
