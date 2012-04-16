#!/usr/bin/perl
#This script checks existing network connections (wifi only) and launches appropriate Synergy instances
#Call this script from /etc/NetworkManager/dispatcher.d/9action_by_network.sh
use strict;
use warnings;
use Moose;

require qw/general_tools.pl monitor_setup.pl synergy_setup.pl/; #Import necessary subroutines;

my $interface = $ARGV[0]; #grab connection interface (e.g. wlan0) from NetworkManager as first argument passed;
my $status = $ARGV[1]; #grab connection status (e.g. up, down) from NetworkManager as second argument passed;

sub retrieve_ssid {
    my $ssid = `iwgetid --raw`; #Grabs just SSID output, but with trailing newline (chomped below);
    chomp $ssid; #Necessary to remove trailing newline so string is pluggable in function calls;
    while (!$ssid) {
        sleep 5; #Wait a bit, giving the interface some time to finalize connection;
        logger("Waiting another second for ssid...\n") #Useful feedback, not so necessary;
        $ssid = retrieve_ssid(); #Try again!;
    }
    logger("Action_by_Network script confirms network SSID to be: '$ssid'\n");
    return $ssid; #Pass SSID back to function caller;
}

my $ssid = retrieve_ssid(); #Get network name!
my $location = ...; #Determine location by calling child script; currently parse_config;
given ($location) {
    when (home)     {...} #Call necessary child scripts;
    when (work)     {...} #Call necessary child scripts;
    ...
}
