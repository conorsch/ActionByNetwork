#!/usr/bin/perl
#This script checks existing network connections (wifi only) and launches appropriate Synergy instances
#Call this script from /etc/NetworkManager/dispatcher.d/9action_by_network.sh
use strict;
use warnings;
use feature qw/switch say/; #case statements and say is better than print;
use ActionByNetwork;

#grab interface (e.g. wlan0) and direction of connection (e.g. up, down) from NetworkManager;
my ($network_interface, $state_change) = @ARGV;

die "Please gimme some args" unless defined(@ARGV);
#my $location; #initialize variable in global scope;
ActionByNetwork::logger("THE ARGS ARE: @ARGV");

given ($state_change) { #Examine network connection status (up or down);

    when (/up/) { #If the network connection is being established...;
        ActionByNetwork::logger("Network connection starting!");

        given ($network_interface) { #examine interface for active connection;

            when (/(wlan|ath)\d+/) { #if active connection appears to be wifi;
                my $location = ActionByNetwork::determine_location; #figure out where we are, based on SSID;
                ActionByNetwork::run_commands($location); #run commands returned by find_commands; 
            }

            when (/eth\d+/) { #if active connection appears to be Ethernet;
                return; #do nothing;
            }

            default { #assume ethernet connection;
                return; #do nothing;
            }
        }
    }

    when (/down/) { #If the network connection is being terminated...;
        ActionByNetwork::logger("Network connection is going down...");
        ActionByNetwork::cleanup_commands; #kill any dangling processes as network goes down;
    }

    default { #failsafe in case input is not properly given;
        ActionByNetwork::logger("Network connection status could not be established; taking no action.");
    }
}
