#!/usr/bin/perl
#This script checks existing network connections (wifi only) and launches appropriate Synergy instances
#Call this script from /etc/NetworkManager/dispatcher.d/9action_by_network.sh
use strict;
use warnings;

require qw/general_tools.pl monitor_setup.pl synergy_setup.pl parse_config.pl/; #Import necessary subroutines;

my $interface = $ARGV[0]; #grab connection interface (e.g. wlan0) from NetworkManager as first argument passed;
my $status = $ARGV[1]; #grab connection status (e.g. up, down) from NetworkManager as second argument passed;

my $ssid = retrieve_ssid(); #Get network name!
my $location = ...; #Determine location by calling child script; currently parse_config;
given ($location) {
    when (home)     {...} #Call necessary child scripts;
    when (work)     {...} #Call necessary child scripts;
    ...
}
