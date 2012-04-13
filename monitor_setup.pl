#!/usr/bin/perl 
#This script sets up user-configured external monitors. It offers two functions,
#one an action to be taken if a monitor is detected, and another if no external monitor is found.
use warnings;
use strict;
use diagnostics;
use feature "switch";
require qw/general_tools.pl/;

our $username;

my $external_monitor = $ARGV[0] || "VGA1"; #Which monitor should be configured? Assume VGA1 if none;
my %monitor_settings = (
        #If using KDE, grab next line from ~/.kde/share/config/krandrrc after using System Settings 
        #'Displays' panel to configure monitor layout and orientation, then choose Save as Default
        VGA1 => 'xrandr --output LVDS1 --pos 0x860 --mode 1366x768 --refresh 60.0186\nxrandr --output VGA1 --pos 1366x0 --mode 2048x1152 --refresh 59.9087\nxrandr --output LVDS1 --primary',
        #DVI1 => '',
        #HDMI1 => '',
        );

sub connect_monitor {
    my $monitor = shift; #Assign easy name to monitor passed from caller;
    logger("External monitor $monitor appears to be connected. Setting it up!"); #Feedback;
    my $command = $monitor_settings{$monitor}; #Retrieve appropriate command from monitor_settings hash;
#system("$command") == 0
#        or die "External monitor setup failed: $?"; #Should translate this error code from 256 to 64
    run_as_user($username, $command);
}

sub disconnect_monitor {
    my $monitor = shift; #Assign easy name to monitor passed from caller;
    logger("External monitor $monitor does not appear to be connected; maintaining single display mode."); #Feedback;
    my $command = "xrandr --output $monitor --off"; #Disable that monitor, because it's not connected; 
    run_as_user($username, $command);
}

my $check = run_as_user($username, "xrandr | grep $external_monitor"); #Check for mention of external monitor, for analysis;
chomp $check; #Probably necessary to remove trailing newline from $check variable;
given ($check) {
    when (/^$external_monitor connected/)    { connect_monitor($external_monitor); } #If monitor is there, set it up;
    when (/^$external_monitor disconnected/) { disconnect_monitor($external_monitor); } #If monitor is absent, disable it;
    default                                  { logger("ERROR: problem while trying to connect to an external monitor."); } #Do nothing;
}

1; #Since this script is reference in calls by other scripts, it must exit with True;
