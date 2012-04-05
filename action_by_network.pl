#!/usr/bin/perl
#This script checks existing network connections (wifi only) and launches appropriate Synergy instances
#Call this script from /etc/NetworkManager/dispatcher.d/9action_by_network.sh
use strict;
use warnings;

require qw/general_tools.pl monitor_setup.pl/; #Import necessary subroutines;

my $interface = $ARGV[0]; #grab connection interface (e.g. wlan0) from NetworkManager as first argument passed;
my $status = $ARGV[1]; #grab connection status (e.g. up, down) from NetworkManager as second argument passed;

package Location;

my %locations = ( "home" => {
                    "type" => "wireless", 
                    "synergy" => "yes",
                    }
                    "work" => {
                    "type" => "Peter", "Status" => "Part-time"} );

sub retrieve_ssid {
    my $ssid = `iwgetid --raw`; #Grabs just SSID output, but with trailing newline (chomped below);
    chomp $ssid; #Necessary to remove trailing newline so string is pluggable in function calls;
    logger("Action_by_Network script confirms network SSID to be: '$ssid'\n") if ($debugging == 1);
    return $ssid; #Pass SSID back to function caller;
}

my $ssid = retrieve_ssid(); #Get network name!
while (!$ssid) {
    sleep 5; #Wait a bit, giving the interface some time to finalize connection;
    logger("Waiting another second for ssid...\n") #Useful feedback, not so necessary;
    $ssid = retrieve_ssid(); #Try again!;
}

check_ssid;
