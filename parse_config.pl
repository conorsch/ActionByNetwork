#!/usr/bin/perl 
#This script performs a YAML configuration file for the ActionByNetwork suite of scripts.
#It takes an SSID from the parent script (action_by_network.pl) and determines a location
#that matches one specified in the configuration file. If it can't find one, it assumes roaming;
use strict;
use warnings;
use YAML::Tiny; #Sufficient for parsing YAML configuration file;
use diagnostics;
use 5.12.0; #There are 'say' calls in here;
use File::Basename 'dirname'; #Since root will execute this script, we'll need to figure out where it's run from;

my $cwd = dirname($0); #Get the current working directory. $0 is the same of the currently running script;
my @required_scripts = qw/general_tools.pl synergy_setup.pl/; #Declare required scripts here, so fullpaths can be grabbed;
foreach (@required_scripts) { #Let's look at all the scripts declared as required above;
    s/(^.*$)/$cwd\/$1/; #Stitch together the path and the name of the required script;
    require $_; #State the requirement;
}

our $location; #Declare location variable as shared, so other scripts have access to it; 

#More thorough conf-file finding should be implemented, e.g. check ~/.abn/conf as well;
my $config_file = 'action_by_network.yml'; #This is the default name for a configuration file;
$config_file =~ s/(^.*$)/$cwd\/$1/; #Stitch together the path and the name of the conf file;
logger("conf file looks like $config_file"); #Debugging feedback, will remove later;

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

sub find_commands { #Once location is known, next step is to build up commands;
    my $location = shift; #Unpack location, supplied by function caller;
    my $commands_to_run = $config->[1]->{$location}->{commands}; #Create hash reference from second section of conf file;
    my @commands_to_run = hashref2array($commands_to_run); #Flatten hash reference into list;
    return @commands_to_run; #Pass back list of commands to run;
}

sub run_commands {
    my @commands = @_; #Unpack list of commands to run from caller;
    foreach my $command (@commands) { #Look at each command;
        given ($command) { #
            when (/synergy/) { 
                my $target_host = $config->[1]->{$location}->{commands}->{synergy}->{ip};    
                say "Found the synergy target! It is: $target_host";
                start_synergy($target_host);  
            }
        }
    }
}

1; #Since this script is reference in calls by other scripts, it must exit with True;
