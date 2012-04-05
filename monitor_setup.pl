#!/usr/env/perl 
#This script sets up user-configured external monitors. It offers two functions,
#one an action to be taken if a monitor is detected, and another if no external monitor is found.
#This script is based heavily on: ost *
use warnings;
use strict;
use feature "switch";
require qw/general_tools.pl/;

#system("export DISPLAY=:0.0"); #This is necessary because root won't be able to call xrandr without knowing the DISPLAY;
#`export DISPLAY=:0.0`; #This is necessary because root won't be able to call xrandr without knowing the DISPLAY;
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
    print "External monitor $monitor appears to be connected. Setting it up!\n";
    my $command = $monitor_settings{$monitor}; #Retrieve appropriate command from monitor_settings hash;
    system("$command") == 0
        or die "External monitor setup failed: $?"; #Should translate this error code from 256 to 64
}

sub disconnect_monitor {
    my $monitor = shift; #Assign easy name to monitor passed from caller;
    logger("External monitor $monitor does not appear to be connected; maintaining single display mode."); 
#Feedback;
    system("xrandr --output $monitor --off"); #Disable that monitor, because it's not connected; 
}

my $check = `xrandr | grep $external_monitor`; #Grab output from xrandr that mentions whether monitor is connected;
chomp $check; #Probably necessary to remove trailing newline from $check variable;

given ($check) {
    when (/^$external_monitor connected/) { 
        connect_monitor($external_monitor);
    }
    when (/^$external_monitor disconnected/) {
        disconnect_monitor($external_monitor);
    }
    default { logger("ERROR: problem while trying to connect to an external monitor."); } #Also do nothing;
}
1; #Since this script is reference in calls by other scripts, it must exit with True;
