#!/usr/bin/perl 
#This script automatically connects to Synergy hosts according to network location
#and to a user-specified list of hosts and IP addresses.
use strict;
use warnings;
use diagnostics;
use 5.12.0;
use File::Basename 'dirname'; #Since root will execute this script, we'll need to figure out where it's run from;

my $cwd = dirname($0); #Get the current working directory. $0 is the same of the currently running script;
my @required_scripts = qw/general_tools.pl/; #Declare required scripts here, so fullpaths can be grabbed;
foreach (@required_scripts) { #Let's look at all the scripts declared as required above;
    s/(^.*$)/$cwd\/$1/; #Stitch together the path and the name of the required script;
    require $_; #State the requirement;
}

sub start_synergy {
    my $connect_to = shift; #Grab target machine to connect to from function call;
    logger("Connecting to Synergy server at $connect_to ...\n");  #A little feedback never hurt anyone;
    kill_synergy(); #In case there are any old instances running, kill them;
    my @custom_args = qw/--yscroll 29/; #Add anything else that should be run. yscroll option fixes bad scroll wheel behavior on Windows hosts;
    system("synergyc @custom_args $connect_to"); #Run the connection, using the target machine grabbed as shift;
}

sub kill_synergy {
    my $pid = `/usr/bin/pgrep synergyc`; #Try to grab PID of an already running instance of synergyc;
    system("/usr/bin/killall synergyc") unless (!$pid); #Ensure that no conflicting Synergy client instances are running (unless there isn't one);
    sleep 2; #Just playing nice here, letting synergyc get killed, probably isn't necessary;
}

1; #Since this script is called by others, it must exit True;
