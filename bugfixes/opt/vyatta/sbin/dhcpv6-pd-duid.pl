#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;
use Config;

my $dhcp6c_duid = '/var/lib/dhcpv6/dhcp6c_duid';
                

sub show_duid {
    
    die "No DUID found\n" if ! -e $dhcp6c_duid;
 
    open(my $FH, '<', $dhcp6c_duid) || die "Error opening [$dhcp6c_duid]: $!\n";
    binmode($FH);
    my ($buf, $val, $len);  
    read($FH, $buf, 2);
    my $endian = $Config{byteorder};
    if ($endian == 1234 or $endian == 12345678) {
        $len = unpack("v", $buf);
    } else {
        $len = unpack("n", $buf);
    }
    for (my $i = 0; $i < $len; $i++) {
        read($FH, $buf, 1);         
        $val .= unpack("H", $buf);
        $val .= unpack("h", $buf);
        $val .= ':' if $i + 1 < $len;
    }                                 
    close($FH);        
    print "DUID $val\n";    
}

sub set_duid {
    my ($duid) = @_;

    open(my $FH, '>', $dhcp6c_duid) || die "Error opening [$dhcp6c_duid]: $!\n";
    binmode($FH);
    
    # print $duid;
    
    $duid =~ s/://g;
    # print $duid;
    my $len = length($duid) / 2;
    my $buf = pack("n", $len);
    print $FH $buf || die "duid length write failed: $!\n";

    my $bin_duid = pack("H*", $duid);
    print $FH $bin_duid || die "duid write failed: $!\n";
    close($FH);
}

sub set_duid_bin {
    my ($duid) = @_;

    open(my $FH, '>', $dhcp6c_duid) || die "Error opening [$dhcp6c_duid]: $!\n";
    binmode($FH);
    
    $duid =~ s/://g;
    my $len = length($duid);
    my $buf = pack("n", $len);
    print $FH $buf || die "write failed\n";

    print $FH $duid;
    close($FH);
}

sub get_mac {
    my ($intf) = @_;
    
    return if !defined $intf;
    my $path = "/sys/class/net/$intf/address";
    return if ! -e $path;
    open my $FH, '<', $path or return;
    my $mac = <$FH>;
    close $FH;
    chomp $mac;
    return $mac;
}

sub gen_duid {
    my ($intf) = @_;

    $intf = 'eth0' if !defined $intf;
    my $mac = get_mac($intf);
    if (!defined $mac) {
        $mac = get_mac('eth0');
    }
    my $duid;
    my $duid_type = 1;
    my $duid_intf = 6;  # ethernet
    my $duid_time = time();
    my @duid_mac = split(/:/, $mac);
    $duid  = chr(0);
    $duid .= chr($duid_type);
    $duid .= chr($duid_type);
    for (my $i=24; $i >= 0; $i -= 8) {
		$duid .= chr(($duid_time >> $i) & 0xff);
	}
    foreach my $b (@duid_mac) {
        $duid .= chr(hex($b));
    }
    set_duid_bin($duid);
}


my ($action, $duid, $intf);

GetOptions("action=s" => \$action,
           "duid=s"   => \$duid,
           "intf=s"   => \$intf,
);

if (! defined $action) {
    print "Must define action\n";
    exit 1;
}

if ($action eq 'show') {
    show_duid();
    exit 0;
}

if ($action eq 'set') {
    if (! defined $duid) {
        print "Must define DUID to set it\n";
        exit 1;
    }
    set_duid($duid);
    exit 0;
}

if ($action eq 'gen') {
    if (! defined $intf) {
        print "Must define intf\n";
        exit 1;
    }
    gen_duid($intf);
    exit 0;
}

if ($action eq 'delete') {
    die "No DUID found\n" if ! -e $dhcp6c_duid;
    system("sudo rm -rf $dhcp6c_duid");
    exit 0;
}

exit 0;
