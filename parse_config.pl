#!/usr/bin/perl 
#This script is a test for parsing a YAML config file.
use strict;
use warnings;
use YAML::Tiny;
use diagnostics;

my $config_file = 'example_config.yml';
my $config = YAML::Tiny->read( $config_file );

my $root = $config->[0]->{rootproperty};
my @locations = $config->[0]->{locations};

print "This is what ROOTTHING looks like: $root\n";
print "This is what LOCATIONS looks like: @locations\n";
