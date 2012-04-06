#!/usr/bin/perl 
#This script opens or closes SSH tunnels as a dynamic SOCKS proxy.
use strict;
use warnings;
require qw/general_tools.pl/; 

our $username; 

#These options should be grabbed from conf file and shared; will implement that later;
my $host = "t"; #Host computer to connect to via SSH (this will reference SSH conf file, so it's OK to use aliases);
my $port = "2002";

sub close_tunnel {
    my $ssh_pid = `ps ax | grep "ssh -D 2002" | head -n 1`; #Grab last first line of ps output
    chomp $ssh_pid; #Away, trailing newline!;
    undef $ssh_pid if ($ssh_pid =~ m/grep/); #We don't want the grep process, which will show up on the ps output;
    if ($ssh_pid) { #Check whether a PID for a pre-existing SSH tunnel was found;
        $ssh_pid =~ s/^ (\d+)(.*)$/$1/; #Grab just the PID from the output (skip first space, get numbers, forget rest;
        print "Pre-existing SSH tunnel found as process $ssh_pid, killing it.\n";
        system("kill $ssh_pid"); #If so, kill it;
    }
}

sub open_tunnel {
    close_tunnel; #In case there's one open, destroy it;
    print "Attempting to open ssh tunnel now...\n";
    run_as_user($username, "ssh -D $port -f -q -N -C $host"); #Perform the actual connection;
    print "SSH tunnel initiated. Enjoy!\n";
}

1; #Since this script is reference in calls by other scripts, it must exit with True;
