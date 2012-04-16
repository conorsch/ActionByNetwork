#!/usr/bin/perl 
#This script is a test for parsing a YAML config file.
use strict;
use warnings;
use YAML::Tiny;
use diagnostics;
#my $config_file = 'example_config.yml';
my $ssid = "BloodOfNorsemen";

my $config_file = 'action_by_network.yml';
my $config = YAML::Tiny->read( $config_file );

#my $root = $config->[0]->{rootproperty};
my $commands = $config->[0]->{home}->{commands};
my $network = $config->[0]->{home}->{network};
my $user = $config->[0]->{user};
my $home_options = $config->[1]->{home};

my $locations = $config->[1];
my @locations = hashref2array($locations);
print "My locations look like: @locations\n";
print "Home options ref points to: " . ref($home_options) . "\n";


my @home_options = hashref2array($home_options);
sub hashref2array {
    my $hashref = shift;
    my @array = (); #
    foreach my $value (sort keys %$hashref) {
        push @array,$value;
    }
    return @array;
}


print "This is what home_options looks like: @home_options\n"; 


