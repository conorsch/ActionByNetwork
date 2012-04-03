#!/usr/bin/perl 
#This script provides a few variables for smooth operation of the ActionByNetwork suite of scripts;
use strict;
use warnings;

my $username = "conor"; #Insert username to run commands as (e.g. synergyc, xrandr);

sub root_exec {
    my @command = shift;
    system("/bin/su $username -c '@command'") == 0
        or die "system command failed (@command): $?";
}
sub logger {
    my $message = shift;
    system("logger -s ActionByNetwork: '$message'");
}

1; #Since this script is reference in calls by other scripts, it must exit with True;
