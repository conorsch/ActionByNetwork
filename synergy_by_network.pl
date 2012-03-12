#!/usr/bin/perl
#This script checks existing network connections (wifi only) and launches appropriate Synergy instances
#Place this file in /etc/NetworkManager/dispatcher.d/99smartsynergy.sh
#Adapted from this script: http://sysadminsjourney.com/content/2008/12/18/use-networkmanager-launch-scripts-based-network-location
use strict;
use warnings;

my $interface = $ARGV[0]; #grab interface from NetworkManager as first argument passed;
my $status = $ARGV[1]; #grab interface from NetworkManager as second argument passed;
my $username = "conor";
my $debugging = 1;

`/usr/bin/logger -s "kja;dslkjg;aldskjg;lsakdjf\n\n\n\n\n\n"`;
my $ssid = retrieve_ssid(); #Get network name!

while (!$ssid) {
    sleep 1; 
    `logger -s "Waiting another second for ssid...\n"`;
    $ssid = `/sbin/iwgetid --raw`; #Try again!;
}
###Insert SSIDs and Synergy host addresses as key-value pairs, e.g. ssid hostname ssid hostname
###User is advised to use IP address of host for best compatibility with Synergy; 
###hostname.local syntax is also supported, but not as reliable (see Synergy documentation);
my %host_list = qw/BloodOfNorsemen 10.0.0.23 ap 192.168.1.110/; 

sub retrieve_ssid {
    $ssid = `iwgetid --raw`; #Grabs just SSID output, but with trailing newline (chomped below);
    chomp $ssid; #Necessary to remove trailing newline so string is pluggable in function calls;
    `logger -s "Action_by_Network script confirms network SSID ot be: '$ssid'\n"`;
    return $ssid;
}

sub connect_monitor {
    my $display = "VGA1"; #Name of the display, as listed by `xrandr`;
    `logger -s "Checking for connected external monitors...\n"`;
    print "Checking for connected external monitors....\n";
    my $check = `xrandr | grep $display`; #Grab output from xrandr that mentions whether monitor is connected;
    chomp $check; #Probably necessary to remove trailing newline from $check variable;
    if ($check =~ m/^$display connected/) { 
        print "External monitor $display appears to be connected. Setting it up!\n";
        `xrandr --output LVDS1 --pos 2048x750 --mode 1366x768 --refresh 60.0186\nxrandr --output VGA1 --pos 0x0 --mode 2048x1152 --refresh 59.9087\nxrandr --output LVDS1 --primary`;
    }
    elsif ($check =~ m/^$display disconnected/) {
        print "External monitor $display does not appear to be connected; maintaining single display mode.\n"; #do nothing
    }
    else { print "ERROR: problem while trying to connect to an external monitor.\n";}
}
sub wait_for_process {
    my $pname = shift; #Grab process name to watch for from function call;
    my $pid = `/usr/bin/pgrep $pname`; #Try to get PID of nm_applt, to make sure it's running;
    while ($pid = undef) { #If process (nm_applt) isn't running, wait until it is;
        sleep 3; #Wait for a bit to give the application a change to start;
        my $pid = `/usr/bin/pgrep $pname`; #Try again to grab the PID;
    }
}
sub start_synergy {
    my $connect_to = shift; #Grab target machine to connect to from function call;
#wait_for_process("nm_applt"); #Wait until we're sure networkmanager is running;
    print "Connecting to $connect_to ...\n"; #A little feedback never hurt anyone;
    `logger -s "Connecting to $connect_to ...\n"`;
    my $pid = `/usr/bin/pgrep synergyc`;
    `/usr/bin/killall synergyc` unless (!$pid); #Ensure that no conflicting Synergy client instances are running (this could be neater);
    sleep 2;
#    `kill $pid` unless ($pid = undef); #Ensure that no conflicting Synergy client instances are running (this could be neater);
    my @custom_args = qw/--yscroll 29/; #Add anything else that should be run. yscroll option fixes bad scroll wheel behavior on Windows hosts;
#    system ("synergyc @custom_args $connect_to"); #Run the c0onnection, using the target machine grabbed as shift;
    `/bin/su $username -c 'synergyc @custom_args $connect_to'`; #Run the connection, using the target machine grabbed as shift;
}
sub check_ssid {
    my $target_host = $host_list{$ssid};# or die "Current network '$ssid' does not have synergy setup configured. Exiting.\n";
    `logger -s "SSID appears to be $ssid\n"` if ($debugging == 1);  #A little feedback never hurt anyone;
    `logger -s "Target to connect to is: $target_host\n"` if ($debugging == 1);
#system ("notify-send 'Identified current network connection as SSID: $ssid\n'"); #This isn't working. Neither backticks nor system works...
    start_synergy($target_host);# or die "Unable to start synergy! Exiting.\n";
}
#connect_monitor; #Regardless of network state, check for external monitor;
check_ssid;
