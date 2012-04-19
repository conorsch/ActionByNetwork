#!/usr/bin/perl 
#This script performs a YAML configuration file for the ActionByNetwork suite of scripts.
#It takes an SSID from the parent script (action_by_network.pl) and determines a location
#that matches one specified in the configuration file. If it can't find one, it assumes roaming;
use strict;
use warnings;
use YAML::Tiny; #Sufficient for parsing YAML configuration file;
use diagnostics;
use 5.12.0; #There are 'say' calls in here;
require qw/general_tools.pl synergy_setup.pl/; #Get necessary boilerplate;

my $ssid = $ARGV[0] || retrieve_ssid(); #Get SSID from parent script; if none given, figure it out;

my $config_file = 'action_by_network.yml'; #This is the default name for a configuration file;
#Better error-handling should be implemented, e.g. check ~/.abn/conf as well;
my $config = YAML::Tiny->read( $config_file ); #Import config file as a hash reference;

sub determine_location { #Let's figure out where we're at; 
    my $ssid = shift; #Unpack $ssid, supplied by function caller;
    my $locations = $config->[1]; #Create hash reference from second section of conf file;
    my @locations = hashref2array($locations); #Flatten hash reference into list;
    foreach my $location (@locations) { #Iterate through list of locations in conf;
        next if $location eq "other"; #other/roaming doesn't have a network, so skip it;
        my $candidate_network = $config->[1]->{$location}->{network}; #Name possibility;
        next unless $candidate_network eq $ssid; #Does our possibility match the ssid?;
        return $location; #If so, pass it back!;
    }
    return "other"; #If we can't find the SSID in the configuration, assume roaming;
}

our $location = determine_location($ssid); #Figure out where we are;
say "Location has been determined to be: $location";
logger("Location has been determined to be: $location"); #Perhaps this should be included in function?;
my @commands = find_commands($location); #Get list of commands to be run for present location;
run_commands(@commands); #Run necessary commands; 

sub find_commands { #Once location is known, next step is to build up commands;
    my $location = shift; #Unpack location, supplied by function caller;
    my $commands_to_run = $config->[1]->{$location}->{commands}; #Create hash reference from second section of conf file;
    my @commands_to_run = hashref2array($commands_to_run); #Flatten hash reference into list;
    say "These are the commands that should be run: @commands_to_run";
    return @commands_to_run; #Pass back list of commands to run;
}

sub run_commands {
    my @commands = @_; #Unpack list of commands to run from caller;
    foreach my $command (@commands) { #Look at each command;
        given ($command) { #
            when (/synergy/) { 
                my $target_host = $config[1]->{$location}->{commands}->{synergy}->{ip};    
                synergy_setup.pl($target_host);  
            }
            when (/tunnel/) { 
                ...; 
            }
        }
    }
}

1; #Since this script is reference in calls by other scripts, it must exit with True;
