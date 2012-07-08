#!/usr/bin/perl 
#This script provides a few variables for smooth operation of the ActionByNetwork suite of scripts;
use strict;
use warnings;
use diagnostics;

our $username = "conor"; #Insert username to run commands as (e.g. synergyc, xrandr);

sub check_depends { #Function to ensure the supplied binaries are present on system;
    my @dependencies = @_; #Unpack list of programs to check installed status;
    my @missing_packages; #Initialize array for storing names of packages not installed;
    foreach my $package (@dependencies) {
        run_as_user("which $package"); #which command returns 0 if found, 1 on failure;
        push @missing_packages, $package if $? != 0; #Not sure whether BASH $? works here;
    }
    return @missing_packages if exists $missing_packages[0]; #Return array if not empty;
}

sub run_as_user {
    my ($username, $command) = @_; #Grab both username to run as and command to run from function caller;
    my $result = `/bin/su $username -c '$command'`; #Run command, grabbing output just in case;
    return $result; #Pass output from command back to function caller;
}

sub hashref2array { #Handy function for flattening hash references into lists;
    my $hashref = shift; #Unpack supplied hash reference;
    my @array = (); #Initialize array so keys from hash reference can be flatted into it;
    foreach my $value (sort keys %$hashref) { #Sort keys, iterate through values;
        push @array,$value; #Add that value to the flatted list created above;
    }
    return @array; #Once down, pass this flatted list back to function caller;
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
