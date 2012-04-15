#!/usr/bin/perl 
#This script is a test for parsing a YAML config file.
use strict;
use warnings;
use YAML::Tiny;
use diagnostics;
#my $config_file = 'example_config.yml';
my $config_file = 'action_by_network.yml';
my $config = YAML::Tiny->read( 'action_by_network.yml' );

#my $root = $config->[0]->{rootproperty};
my $commands = $config->[0]->{home}->{commands};
my $network = $config->[0]->{home}->{network};
my $user = $config->[0]->{user};
my $home_options = $config->[0]->{home};



print ref($home_options) . "\n";
print "The commands ref points to a: " . ref($commands) . "\n";
print "The home_options ref points to a: " . ref($home_options) . "\n";
#print "This is what ROOTTHING looks like: $root\n";
print "This is what network looks like: $network\n";
print "This is what user looks like: $user\n";
print "This is what commands looks like: $commands\n";




my @home_options = hashref2array($home_options);
sub hashref2array {
    my $hashref = shift;
    my @array = (); #
    foreach my $value (keys %$hashref) {
        push @array,$value;
    }
    return @array;
}


print "This is what home_options looks like: @home_options";
print "\n";

my @home_commands = ();
foreach my $command (sort keys %$commands) {
    push @home_commands,$command;
}
print "This is what home_commands looks like: @home_commands";

print "\n";


