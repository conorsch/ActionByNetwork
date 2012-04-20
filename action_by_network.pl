#!/usr/bin/perl
#This script checks existing network connections (wifi only) and launches appropriate Synergy instances
#Call this script from /etc/NetworkManager/dispatcher.d/9action_by_network.sh
use strict;
use warnings;
use 5.12.0;
use File::Basename 'dirname'; #Since root will execute this script, we'll need to figure out where it's run from;

my $cwd = dirname($0); #Get the current working directory. $0 is the same of the currently running script;
my @required_scripts = qw/parse_config.pl general_tools.pl/; #Declare required scripts here, so fullpaths can be grabbed;
foreach (@required_scripts) { #Let's look at all the scripts declared as required above;
    s/(^.*$)/$cwd\/$1/; #Stitch together the path and the name of the required script;
    require $_; #State the requirement;
}

my $network_interface = $ARGV[0]; #grab connection interface (e.g. wlan0) from NetworkManager as first argument passed;
my $connection_up_or_down = $ARGV[1]; #grab connection status (e.g. up, down) from NetworkManager as second argument passed;

given ($connection_up_or_down) { #Examine network connection status (up or down);
    when (/up/) { #If the network connection is being established...;
        my $ssid = retrieve_ssid(); #Get network name!
        our $location = determine_location($ssid); #Figure out where we are, based on SSID;
        say "Location has been determined to be: $location"; #Debugging feedback, will remove later;
        logger("Location has been determined to be: $location"); #Perhaps this should be included in function?;
        my @commands = find_commands($location); #Get list of commands to be run for present location;
        run_commands(@commands); #Run necessary commands; 
    }
    when (/down/) { #If the network connection is being terminated...;
        logger("Network connection terminated, not taking any action.");
        ...; #Shutdown procedures such as removing connections should be implemented here;
    }
    default {
        logger("Network connection status could not be established; taking no action.";
    }
}
