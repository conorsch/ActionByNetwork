#!/usr/bin/perl 
#This script provides a few variables for smooth operation of the ActionByNetwork suite of scripts;
use strict;
use warnings;

my $username = "conor"; #This must be declared manually!

sub root_exec {
    my $command = shift;
    system("/bin/su $username -c $command") == 0
        or die "system command failed ($command): $?";
}
sub log_this {
    my $message = shift;
    system("logger -s $message");
}


