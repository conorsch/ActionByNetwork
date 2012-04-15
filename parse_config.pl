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
my \@commands = $config->[0]->{home}->{commands};
my $network = $config->[0]->{home}->{network};
my $user = $config->[0]->{user};

#print "This is what ROOTTHING looks like: $root\n";
print "This is what network looks like: $network\n";
print "This is what user looks like: $user\n";
print "This is what commands looks like: @commands\n";
