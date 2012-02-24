#!/usr/bin/perl
#This script checks existing network connections (wifi only) and launches appropriate Synergy instances
#Place this file in /etc/NetworkManager/dispatcher.d/99smartsynergy.sh
#Adapted from this script: http://sysadminsjourney.com/content/2008/12/18/use-networkmanager-launch-scripts-based-network-location
use strict;
use warnings;

my $interface = $ARGV[0]; #grab interface from NetworkManager as first argument passed;
my $status = $ARGV[1]; #grab interface from NetworkManager as second argument passed;
my $ssid = `iwgetid --raw`; #Grabs just SSID output, but with trailing newline (chomped below)
chomp $ssid; #Necessary to remove trailing newline so string is pluggable in function calls

sub wait_for_process {
    my $pname = shift; #Grab process name to watch for from function call
    my $pid = `/usr/bin/pgrep $pname`; #Try to get PID of nm_applt, to make sure it's running
    while ($pid = undef) { #If process (nm_applt) isn't running, wait until it is
        sleep 3;
        my $pid = `/usr/bin/pgrep $pname`;
    }
}

sub start_synergy {
    my $connect_to = shift;
    wait_for_process("nm_applt");
    `notify-send "Connecting to $connect_to ...\n"`;
    `killall synergyc`;
    `synergyc $connect_to`;
}

sub check_ssid {
    my %connection_list = qw/BloodOfNorsemen 10.0.0.23 ap PCLAB0.local/; #List key-value pairs, format: ssid hostname ssid hostaname
    my $target_host = $connection_list{$ssid} or die "Current network $ssid does not have synergy setup configured. Exiting.\n";
    print "SSID appears to me $ssid\n";
    print "Target to connect to is: $target_host\n";
    `notify-send "Identified current network connection as SSID: $ssid\n"`;
    start_synergy($target_host); #die doesn't work here or die "Unable to start synergy! Exiting.\n";
}
#check_ssid if ($interface = "wlan0" && $status = "up");
if ($interface = "wlan0" && $status = "up") { #Only run script if a working wireless connection is detected
    print "Wireless network connection detected, running check on whether Synergy configuration exists for this network.\n";
    check_ssid;
}
else {
    `notify-send "Network connection wonky; not starting synergy. SSID is: $ssid\n"`;
}

        
