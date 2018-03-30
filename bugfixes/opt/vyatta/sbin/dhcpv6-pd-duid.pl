#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;
use Config;

# my $dhcp6c_duid = '/var/lib/dhcpv6/dhcp6c_duid';
my $dhcp6c_duid = '';

### 
# Initial debugging block for being able to do testing to isolate the behavior.
#  This block should be removed before attempting to send this back to Ubiquiti. 
###
if (defined($ENV{'DUID_FILE'})) {
	$dhcp6c_duid = $ENV{'DUID_FILE'};
} else {
	$dhcp6c_duid = '/var/lib/dhcpv6/dhcp6c_duid';
}
                
print("Using File: ", $dhcp6c_duid,"\n");
###

sub show_duid {
    
    die "No DUID found\n" if ! -e $dhcp6c_duid;
 
    open(my $FH, '<', $dhcp6c_duid) || die "Error opening [$dhcp6c_duid]: $!\n";
    binmode($FH);
    my ($buf, $val, $len, $pack_template);  
    read($FH, $buf, 2);
    my $endian = $Config{byteorder};
    if ($endian == 1234 or $endian == 12345678) {
        $pack_template = 'v'; 
    } else {
        $pack_template = 'n'; 
    }
    $len = unpack($pack_template, $buf);

    for (my $i = 0; $i < $len; $i++) {
        read($FH, $buf, 1);         
        $val .= unpack("H", $buf);
	#print("debug 1: ", $val, "\n");
        $val .= unpack("h", $buf);
	#print("debug 2: ", $val, "\n");
        $val .= ':' if $i + 1 < $len;
	#print("debug 3: ", $val, "\n");
    }                                 
    close($FH);        
    print "DUID $val\n";    
}

sub set_duid {
    print("Calling set_duid\n");
    my ($duid) = @_;
    my ($pack_template);
    if ($Config{byteorder} == 1234 or $Config{byteorder} == 12345678) {
        $pack_template = 'v'; 
    } else {
        $pack_template = 'n'; 
    }

    open(my $FH, '>', $dhcp6c_duid) || die "Error opening [$dhcp6c_duid]: $!\n";
    binmode($FH);
    
    # print $duid;
    
    $duid =~ s/://g;
    # print $duid;
    my $len = length($duid) / 2;
    my $buf = pack($pack_template, $len);
    print $FH $buf || die "duid length write failed: $!\n";

    my $bin_duid = pack("H*", $duid);
    print $FH $bin_duid || die "duid write failed: $!\n";
    close($FH);
}

sub set_duid_bin {
    print("Calling set_duid_bin\n");
    my ($duid) = @_;
    my ($pack_template);
    if ($Config{byteorder} == 1234 or $Config{byteorder} == 12345678) {
        $pack_template = 'v'; 
    } else {
        $pack_template = 'n'; 
    }


    open(my $FH, '>', $dhcp6c_duid) || die "Error opening [$dhcp6c_duid]: $!\n";
    binmode($FH);
    
    $duid =~ s/://g;
    my $len = length($duid);
    print("Length: ", $len, "\n");
    # This is crazy because the generated length is 13
    my $buf = pack($pack_template, $len);
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
    # Hypothetically it seems this function is attempting to implement RFC3315
    # section 9.2 (DUID Based on Link-layer Address Plus Time [DUID-LLT])...
    # That being said, the RFC states to use 32 bits for time while that for
    # loop is only using 24.  In addition, the hardware type states to use 16 bits
    #
    my ($intf) = @_;

    $intf = 'eth0' if !defined $intf;
    my $mac = get_mac($intf);
    if (!defined $mac) {
        $mac = get_mac('eth0');
    }
    my $duid;
    my $duid_type = 1;
    # Why is this being defined but not used?
    my $duid_intf = 6;  # ethernet
    my $duid_time = time();
    my @duid_mac = split(/:/, $mac);
    print("DUID Length: ", length($duid), "\n");
    # Inset a null character
    $duid  = chr(0);
    # Inset ASCII Start of Header (character code 1)
    $duid .= chr($duid_type);
    # Insert a second ASCII SOH, because why not?
    $duid .= chr($duid_intf);
    
    for (my $i=32; $i >= 0; $i -= 8) {
	$duid .= chr(($duid_time >> $i) & 0xff);
	print("DUID: ", $duid, "\n");
	}
    foreach my $b (@duid_mac) {
        $duid .= chr(hex($b));
	    print("DUID Length: ", length($duid), "\n");
    }

    print("DUID Length: ", length($duid), "\n");
    print(length($duid));
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
