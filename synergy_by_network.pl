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
        sleep 3; #Wait for a bit to give the application a change to start;
        my $pid = `/usr/bin/pgrep $pname`; #Try again to grab the PID 
    }
}
sub start_synergy {
    my $connect_to = shift; #Grab target machine to connect to from function call
    wait_for_process("nm_applt"); #Wait until we're sure networkmanager is running
    `notify-send "Connecting to $connect_to ...\n"`; #A little feedback never hurt anyone
    `killall synergyc`; #Ensure that no conflicting Synergy client instances are running (this could be neater);
    `synergyc $connect_to`; #Run the connection, using the target machine grabbed as shift;
}
sub check_ssid {
    my %connection_list = qw/BloodOfNorsemen 10.0.0.23 ap PCLAB0.local/; #List key-value pairs, format: ssid hostname ssid hostaname
    my $target_host = $connection_list{$ssid} or die "Current network $ssid does not have synergy setup configured. Exiting.\n";
    print "SSID appears to be $ssid\n";
    print "Target to connect to is: $target_host\n";
    `notify-send "Identified current network connection as SSID: $ssid\n"`; #A little feedback never hurt anyone;
    start_synergy($target_host); #die doesn't work here or die "Unable to start synergy! Exiting.\n";
#Would be nice to have "or die" after start_synergy call, but gotta look up error codes
}
#
if ($interface = "wlan0" && $status = "up") { #Only run script if a working wireless connection is detected
    print "Wireless network connection detected, running check on whether Synergy configuration exists for this network.\n";
    check_ssid;
}
else {
    `notify-send "Network connection wonky; not starting synergy. SSID is: $ssid\n"`;
}

        
