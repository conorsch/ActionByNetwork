#!/usr/bin/perl 
#This script provides a few variables for smooth operation of the ActionByNetwork suite of scripts;
use strict;
use warnings;
use diagnostics;

our $username = "conor"; #Insert username to run commands as (e.g. synergyc, xrandr);

sub check_depends { #Function to ensure the supplied binaries are present on system;
    ...;
}

sub check_network_state { #Find out whether there is currently an active network connection;
    ...;
}

sub retrieve_ssid {
    my $ssid = `iwgetid --raw`; #Grabs just SSID output, but with trailing newline (chomped below);
    chomp $ssid; #Necessary to remove trailing newline so string is pluggable in function calls;
    while (!$ssid) {
        sleep 5; #Wait a bit, giving the interface some time to finalize connection;
        logger("Determining SSID for current connection...\n"); #Useful feedback, not so necessary;
        $ssid = retrieve_ssid(); #Try again!;
    }
    logger("Action_by_Network script confirms network SSID to be: '$ssid'\n");
    return $ssid; #Pass SSID back to function caller;
}

sub logger {
    my $message = shift; #Grab string to be logged from function caller;
    system("logger -s ActionByNetwork: '$message'"); #Send to system log;
}

sub run_as_user {
    my ($username, $command) = @_; #Grab both username to run as and command to run from function caller;
    my $result = `/bin/su $username -c '$command'`; #Run command, grabbing output just in case;
    return $result; #Pass output from command back to function caller;
}

sub request_interfaces {
#This function creates a list of possible network interfaces on the system, ignoring the loopback interface;
    my @interfaces; #Set up a list to store interface values in;
    my @ifconfig = `ifconfig`; #Grab output of ifconfig for parsing;
    foreach my $line (@ifconfig) {
        next if ($line =~ m/^\s/); #Interface names are left-justified, so ignore lines with leading whitespace;
        chomp $line; #Remove trailing whitespace;
        $line =~ s/(^\w*)(\s*.*$)/$1/; #Grab the anchored word, trash the rest of the line;
        push @interfaces, $line unless $line eq "lo"; #Add interface to list, unless it's loopback;
    }
    return @interfaces; #Pass back results to function caller;
}

1; #Since this script is reference in calls by other scripts, it must exit with True;
