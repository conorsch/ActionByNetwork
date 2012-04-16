#!/usr/bin/perl 
#This script performs a YAML configuration file for the ActionByNetwork suite of scripts.
#It takes an SSID from the parent script (action_by_network.pl) and determines a location
#that matches one specified in the configuration file. If it can't find one, it assumes roaming;
use strict;
use warnings;
use YAML::Tiny; #Sufficient for parsing YAML configuration file;
use diagnostics;
use 5.12.0; #There are 'say' calls in here;
#require qw/general_tools.pl/; #Get necessary boilerplate;

#my $ssid = $ARGV[0] || retrieve_ssid(); #Get SSID from parent script; if none given, figure it out;
my $ssid = "BloodOfNorsemen";

my $config_file = 'action_by_network.yml'; #This is the default name for a configuration file;
#Better error-handling should be implemented, e.g. check ~/.abn/conf as well;
my $config = YAML::Tiny->read( $config_file ); #Import config file as a hash reference;

#Let's start splitting up this hash reference into workable pieces;
my $commands = $config->[0]->{home}->{commands};
my $network = $config->[0]->{home}->{network};
my $user = $config->[0]->{user};
my $home_options = $config->[1]->{home};
my $home_network = $config->[1]->{home}->{network};

sub determine_location { #Let's figure out where we're at; 
    my $ssid = shift;
    my $locations = $config->[1]; #Create hash reference from second section of conf file;
    my @locations = hashref2array($locations); #Flatten hash reference into list;
    foreach my $location (@locations) { #Iterate through list of locations in conf;
        my $candidate_location = $config->[1]->{$location}->{network}; #Name possibility;
        next unless $candidate_location eq $ssid; #Does our possibility match the ssid?;
        return $candidate_location; #If so, pass it back!;
    }
    return "other"; #If we can't find the SSID in the configuration, assume roaming;
}

our $location = determine_location($ssid); #Figure out where we are;
say "Location has been determined to be: $location";
#logger("Location has been determined to be: $location"); #Perhaps this should be included in function?;

sub hashref2array { #Handy function for flattening hash references into lists;
    my $hashref = shift; #Unpack supplied hash reference;
    my @array = (); #
    foreach my $value (sort keys %$hashref) {
        push @array,$value;
    }
    return @array;
}
