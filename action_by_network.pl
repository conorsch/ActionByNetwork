#!/usr/bin/perl
#This script checks existing network connections (wifi only) and launches appropriate Synergy instances
#Call this script from /etc/NetworkManager/dispatcher.d/9action_by_network.sh
use strict;
use warnings;
use Moose;

require qw/general_tools.pl monitor_setup.pl syneryg_setup.pl/; #Import necessary subroutines;

my $interface = $ARGV[0]; #grab connection interface (e.g. wlan0) from NetworkManager as first argument passed;
my $status = $ARGV[1]; #grab connection status (e.g. up, down) from NetworkManager as second argument passed;




package Location {

    has 'label', is => 'ro', isa => 'Str'; #Name the location, as a read-only string;
    has 'commands', is => 'ro', isa => 'ArrayRef'; #Provide list of actions, as read-only array reference;


    my $at_home = Location->new();
    my $at_work = Location->new();
    my $on_the_road = Location->new();

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

