=head1 NAME

ActionByNetwork - Perl module for automating actions according to network state

=head1 SYNOPSIS

use ActionByNetwork;

=head1 DESCRIPTION

Creates and maintains dotfile of user preferences for notifications about quota usage.

Methods to build list of valid home directories, update user preferences, and retrieve 
user preferences. Supports customizing frequency of notications and percent of quota 
usage that generates email. 

=head2 Methods

=over 4

=item * get_users([$home_pattern])

Walks through the /etc/passwd file and builds a list of valid home directories. 
Function supports argument of pattern to identify valid homes. If none is given,
pattern defaults to '^/home[0-9]+/', to match SEAS user home directories.

The function returns two hash references, with the structures: 

#===============================================================================
=cut
#!/usr/bin/perl
package ActionByNetwork; #name our package;
use strict;
use warnings;
use feature qw/switch say/; #case statements and say is better than print;
use Config::Simple; #for configuration file processing;
use YAML::Tiny;
use Data::Dumper;

#my $config_file = '/home/conor/gits/ActionByNetwork/action_by_network.yml';
#my $config = YAML::Tiny->read( $config_file ) #Import config file as a hash reference;
#    or die "Unable to read configuration file at '$config_file'";

my $config_file = '/home/conor/gits/ActionByNetwork/abn.conf';
my $config = Config::Simple->new( $config_file ) #Import config file as a hash reference;
    or die "Unable to read configuration file at '$config_file'";
my %config = $config->vars;


sub retrieve_ssid { #return SSID of current wireless connection;
    my $ssid = `/sbin/iwgetid --raw`; #capture SSID from iwgetid system call;
    while (!$ssid) { #if $ssid wasn't found...;
        sleep 5; #wait a bit, giving the interface some time to finalize connection;
        logger("Determining SSID for current connection ($ssid)...\n"); #provide feedback;
        my $ssid = `/sbin/iwgetid --raw`; #capture SSID from iwgetid system call;
    }
    chomp $ssid; #remove pesky trailing newline;
    logger("Action_by_Network script confirms network SSID to be: '$ssid'\n"); #provide feedback;
    return $ssid; #pass SSID back to function caller;
}

sub retrieve_device { #return device name for active network connection;
    `/usr/bin/nm-online -t 1`; #run check (returns 0 for success, 1 for failure);
    if ( $? == 0 ) { #check whether connection check reported success;
        my @device_check = `/usr/bin/nmcli dev`; #grab list of devices managed by NetworkManager;
        foreach my $line (@device_check) { #look at output from `nmcli dev` check;
            chomp $line; #remove pesky trailing newline;
            next unless $line =~ m/connected/; #skip unless line contains "connected";
            my @line = split('\s', $line); #split current line on whitespace;
            my $device = shift @line; #grab first column of this line, the device name;
            return $device; #take first connected device found;
        }
    }
    else { #if online check failed;
        return; #return failure;
    }
}

sub logger { #write to /var/log/syslog using 'logger -s';
    my $message = shift; #Grab string to be logged from function caller;
    system("logger -s ActionByNetwork: '$message'"); #Send to system log with ActionByNetwork prefixed;
}

sub determine_location { #return current location by looking up SSID in conf file;
    my $ssid = retrieve_ssid; #get ssid from subroutine;
    say "DUMPER: " . Dumper($config);
    my $work_network = $config->param('work.ssid');
    say "WORK NETWORK looks like: '$work_network'";
    my $location; #initialize variable in proper scope;
    my @locations; #initialize variable in proper scope;
    foreach my $preference (sort keys %config) {
        chomp $preference;
        my @block_pref = split('\.', $preference);
        my ($location, $option) = @block_pref;
        push @locations, $location;
#        say "LOCATION: $location OPTION: $option VALUE: $config_vars{$key}";
    }
    foreach my $loc (@locations) { 
        my $ssid_pref = $config->param("$loc.ssid");
        next unless defined($ssid_pref);
        if ($ssid_pref eq $ssid) { 
            say "SUCCESS! $ssid_pref" if $ssid_pref eq $ssid;
            $location = $loc;
            last;
        }
    }

#    if ( exists $locations->{network} ) { #if current SSID exists in configuration file;
#
#        say "LOCATION looks like: '$location'";
#        $location = $locations->{$ssid}; #retrieve location for this SSID;
#    }
#    else { #if SSID is not found in conf file;
#        $location = 'other'; #assume roaming and report location as 'other';
#    }
#
    logger("Location has been determined to be '$location'");
    say "Location has been determined to be '$location'";
    return $location; #pass current location back to function caller;
}
sub parse_config { #read in config file for ActionByNetwork; 
    my $config_file = shift;
    my $config = YAML::Tiny->read( $config_file ); #Import config file as a hash reference;
}

##### Cleanup commands, for when network goes down and processes should be killed;
sub cleanup_commands { #kill any processes before network goes down;
    my @commands_to_kill = qw/synergyc/;
    my $command = 'synergyc';
    logger("Killing exiting $command process...");
    system("/usr/bin/killall", $command) ; #Ensure that no conflicting Synergy client instances are running (unless there isn't one);
    foreach my $command (@commands_to_kill) { #look at each command in the list;
        logger("Killing exiting $command process...");
        system("/usr/bin/killall", $command) ; #Ensure that no conflicting Synergy client instances are running (unless there isn't one);
    }
}

sub check_network_state { #Find out whether there is currently an active network connection;
    my $check = `/usr/bin/nmcli nm | tail -n 1 | awk '{print $2}'`; #Find out whether connected;
    return 1 if $check eq "connected"; #If 'connected' is found, then report True; 
    return; #Otherwise, bare return (false);
}
 

sub get_commands { #return list of commands to be run for current location;
    my $location = shift; #unpack location from function caller;
    my @commands_to_run = $config{"$location.commands"} #read list of commands to run from config;
        or return; #return failure if no commands are given;
    return @commands_to_run; #Pass back list of commands to run;
}

sub run_commands { #run specified commands according to config file;
    my $location = shift; #unpack location from function caller;
    my @commands = get_commands($location); #unpack list of commands to run from caller;
    foreach my $command (@commands) { #look at each command in the list passed in;
        given ($command) { #begin case statement for commands;

            when (/synergy/) { #if specified command is 'synergy';
                my $target_host = $config{"$location.synergy"};    
                logger("Starting synergyc...");
                system('/usr/bin/synergyc', $target_host); #start synergyc, connecting to host;
            }

            when (/monitor/) { #if specified command is 'monitor';
                system("monitor_setup.pl");
                logger("TESTING MONITOR ACTION NOW");
            }

            when (/custom/) { #if user has specified command in conf file;
                my $custom_command = $config->[1]->{$location}->{commands}->{custom};    
                given ($custom_command) { #analyze user-specified command;
                    when (/rm /) { #if it looks like there's a remove command;
                        die "Unable to execute custom command '$custom_command'; Looks like rm!";
                    }
                    when (/^\//) { #if command does not begin with '/';
                        die "Unable to execute custom command '$custom_command'; Specify fullpath in conf file! ";
                    }
                    default { #if command looks safe;
                        system("$command"); #run user-specified command;
                    }
                }
            }
        }
    }
}
