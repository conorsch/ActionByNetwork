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
my @required_scripts = qw/general_tools.pl synergy_setup.pl monitor_setup.pl/; #Declare required scripts here, so fullpaths can be grabbed;
foreach (@required_scripts) { #Let's look at all the scripts declared as required above;
    s/(^.*$)/$cwd\/$1/; #Stitch together the path and the name of the required script;
    require $_; #State the requirement;
}

our $location; #Declare location variable as shared, so other scripts have access to it; 

#More thorough conf-file finding should be implemented, e.g. check ~/.abn/conf as well;
my $config_file = 'action_by_network.yml'; #This is the default name for a configuration file;
$config_file =~ s/(^.*$)/$cwd\/$1/; #Stitch together the path and the name of the conf file;
#my $prefered_config_file = "/home/$username/.abn.conf/"; #This wouldn't actually work;
#if ( -e $preferred_config_file ) { ...; } #To be implemented later;

logger("conf file looks like $config_file"); #Debugging feedback, will remove later;

my $config = YAML::Tiny->read( $config_file ); #Import config file as a hash reference;
#our $username = $config->{0}->{user}; #Grab username from conf file, share it around;

sub determine_location { #return current location by looking up SSID in conf file;
    my $ssid = shift; #unpack $ssid from function caller;
    my $locations = $config; #create hash reference from second section of conf file;
    if ( exists $locations->{$ssid} ) { #if current SSID exists in configuration file;
        return $locations->{$ssid}; #pass current location back to function caller;
    }
    else { #if SSID is not found in conf file;
        return 'other'; #assume roaming and report location as 'other';
    }
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
            when (/monitor/) {
                system("monitor_setup.pl");
                say "TESTING MONITOR ACTION NOW";
                logger("TESTING MONITOR ACTION NOW");
            }

        }
    }
}

1; #Since this script is reference in calls by other scripts, it must exit with True;
