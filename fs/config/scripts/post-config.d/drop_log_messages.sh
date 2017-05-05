#!/bin/sh

if [ ! -L /etc/rsyslog.d/drop-messages.conf ]; then
    ln -s /config/user-data/rsyslog/drop-messages.conf /etc/rsyslog.d/
    /etc/init.d/rsyslog restart
fi

exit 0
