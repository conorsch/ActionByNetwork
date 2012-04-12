#!/usr/bin/perl 
#This script automatically connects to Synergy hosts according to network location
#and to a user-specified list of hosts and IP addresses.
use strict;
use warnings;

require qw/general_tools.pl/;

###Insert SSIDs and Synergy host addresses as key-value pairs, e.g. ssid hostname ssid hostname
###User is advised to use IP address of host for best compatibility with Synergy; 
###hostname.local syntax is also supported, but not as reliable (see Synergy documentation);
my %host_list = qw/BloodOfNorsemen 10.0.0.30 ap 192.168.1.110/; 

sub start_synergy {
    my $connect_to = shift; #Grab target machine to connect to from function call;
    logger("Connecting to $connect_to ...\n");  #A little feedback never hurt anyone;
    kill_synergy();
    my @custom_args = qw/--yscroll 29/; #Add anything else that should be run. yscroll option fixes bad scroll wheel behavior on Windows hosts;
    system("synergyc @custom_args $connect_to"); #Run the connection, using the target machine grabbed as shift;
}

sub kill_synergy {
    my $pid = `/usr/bin/pgrep synergyc`; #Try to grab PID of an already running instance of synergyc;
    system("/usr/bin/killall synergyc") unless (!$pid); #Ensure that no conflicting Synergy client instances are running (unless there isn't one);
    sleep 2; #Just playing nice here, letting synergyc get killed, probably isn't necessary;
}

#return if (@ARGV[0] = 0); #Exit if no target was supplied by caller;
start_synergy($target_host);

1;
