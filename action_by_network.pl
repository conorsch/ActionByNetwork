#!/usr/bin/perl
#This script checks existing network connections (wifi only) and launches appropriate Synergy instances
#Place this file in /etc/NetworkManager/dispatcher.d/99smartsynergy.sh
#Adapted from this script: http://sysadminsjourney.com/content/2008/12/18/use-networkmanager-launch-scripts-based-network-location
use strict;
use warnings;

require qw/general_tools.pl hotplug_monitor.pl/; #Import necessary subroutines;

my $interface = $ARGV[0]; #grab connection interface (e.g. wlan0) from NetworkManager as first argument passed;
my $status = $ARGV[1]; #grab connection status (e.g. up, down) from NetworkManager as second argument passed;
my $debugging = 1; #Will take this out later, used for providing more verbose feedback in syslog;
my $root_exec; "/bin/su $username -c"; #This command properly runs various programs from root as $username; (better as sub?);

my $ssid = retrieve_ssid(); #Get network name!
while (!$ssid) {
    sleep 5; #Wait a bit, giving the interface some time to finalize connection;
    `logger -s "Waiting another second for ssid...\n"` if ($debugging == 1); #Useful feedback, not so necessary;
    $ssid = retrieve_ssid(); #Try again!;
}
###Insert SSIDs and Synergy host addresses as key-value pairs, e.g. ssid hostname ssid hostname
###User is advised to use IP address of host for best compatibility with Synergy; 
###hostname.local syntax is also supported, but not as reliable (see Synergy documentation);
my %host_list = qw/BloodOfNorsemen 10.0.0.30 ap 192.168.1.110/; 

sub retrieve_ssid {
    $ssid = `iwgetid --raw`; #Grabs just SSID output, but with trailing newline (chomped below);
    chomp $ssid; #Necessary to remove trailing newline so string is pluggable in function calls;
    `logger -s "Action_by_Network script confirms network SSID to be: '$ssid'\n"` if ($debugging == 1);
    return $ssid; #Pass SSID back to function call;
}
sub start_synergy {
    my $connect_to = shift; #Grab target machine to connect to from function call;
    print "Connecting to $connect_to ...\n"; #A little feedback never hurt anyone;
    `logger -s "Connecting to $connect_to ...\n"`;
    my $pid = `/usr/bin/pgrep synergyc`; #Try to grab PID of an already running instance of synergyc;
    `/usr/bin/killall synergyc` unless (!$pid); #Ensure that no conflicting Synergy client instances are running (unless there isn't one);
    sleep 2; #Just playing nice here, letting synergyc get killed, probably isn't necessary;
    my @custom_args = qw/--yscroll 29/; #Add anything else that should be run. yscroll option fixes bad scroll wheel behavior on Windows hosts;
    `synergyc @custom_args $connect_to`; #Run the connection, using the target machine grabbed as shift;
}
sub check_ssid {
    my $target_host = $host_list{$ssid};# or die "Current network '$ssid' does not have synergy setup configured. Exiting.\n";
    `logger -s "SSID appears to be $ssid\n"` if ($debugging == 1);  #A little feedback never hurt anyone;
    `logger -s "Target to connect to is: $target_host\n"` if ($debugging == 1);
    start_synergy($target_host);# or die "Unable to start synergy! Exiting.\n";
}
#connect_monitor; #Regardless of network state, check for external monitor;
check_ssid;
