#!/usr/bin/perl 
#This script provides a few variables for smooth operation of the ActionByNetwork suite of scripts;
use strict;
use warnings;
use diagnostics;

our $username = "conor"; #Insert username to run commands as (e.g. synergyc, xrandr);

sub logger {
    my $message = shift;
    system("logger -s ActionByNetwork: '$message'");
}

sub run_as_user {
    my ($username, $command) = @_; #Grab both username to run as and command to run from function caller;
    my $result = `/bin/su $username -c '$command'`; #Run 
    return $result;
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
