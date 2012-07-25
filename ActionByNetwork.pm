=head1 NAME

ActionByNetwork - Perl module for automating actions according to network state

=head1 SYNOPSIS

use ActionByNetwork;

=head1 DESCRIPTION

Allows for automation of tasks based on location, as defined by network ID. 

=head2 Methods

=over 4

=item * retrieve_ssid([$home_pattern])

Gets SSID.

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


my $config = get_config();

sub get_config_yaml {
    my $config_file = '/home/conor/gits/ActionByNetwork/abn.yml';
    my @config = YAML::Tiny->read( $config_file ) #Import config file as a hash reference;
        or die "Unable to read configuration file at '$config_file'";

    return $config;

}
sub get_config {
    my $config_file = '/home/conor/gits/ActionByNetwork/abn.conf';
    my $config = Config::Simple->new( $config_file ) #Import config file as a hash reference;
        or die "Unable to read configuration file at '$config_file'";
    my %config = $config->vars;

    return \%config;

}


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
    my $location; #initialize variable in proper scope;
    my @locations; #initialize variable in proper scope;
    foreach my $preference (sort keys %{$config}) {
        my @block_pref = split('\.', $preference);
        my ($location, $option) = @block_pref;
        my $ssid_pref = $config->{"$location.ssid"};
        next unless defined($ssid_pref);
        if ($ssid_pref eq $ssid) { 
            logger("Location has been determined to be '$location'");
            return $location; #pass current location back to function caller;
            last;
        }
        else { #if no ssid match was found;
            return; #return failure;
        }
#        say "LOCATION: $location OPTION: $option VALUE: $config_vars{$key}";
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
}

##### Cleanup commands, for when network goes down and processes should be killed;
sub cleanup_commands { #kill any processes before network goes down;
    my @commands_to_kill = qw/synergyc/;
#    system("/usr/bin/killall", $command) ; #Ensure that no conflicting Synergy client instances are running (unless there isn't one);
    foreach my $command (@commands_to_kill) { #look at each command in the list;
        logger("Killing existing $command process...");
#        run_as_user('conor', "/usr/bin/killall -9 $command") ; #Ensure that no conflicting Synergy client instances are running (unless there isn't one);
        system("/usr/bin/killall -9 $command") ; #Ensure that no conflicting Synergy client instances are running (unless there isn't one);
    }
}

sub check_network_state { #Find out whether there is currently an active network connection;
    my $check = `/usr/bin/nmcli nm | tail -n 1 | awk '{print $2}'`; #Find out whether connected;
    return 1 if $check eq "connected"; #If 'connected' is found, then report True; 
    return; #Otherwise, bare return (false);
}
 
sub run_as_user {
    my ($username, $command) = @_; #Grab both username to run as and command to run from function caller;
    my $result = `/bin/su $username -c '$command'`; #Run command, grabbing output just in case;
    return $result; #Pass output from command back to function caller;
}

sub get_commands { #return list of commands to be run for current location;
    my $location = shift; #unpack location from function caller;
    my @commands_to_run = $config->{"$location.commands"} #read list of commands to run from config;
        or return; #return failure if no commands are specified in config file;
    return @commands_to_run; #Pass back list of commands to run;
}

sub run_commands { #run specified commands according to config file;
    my $location = shift; #unpack location from function caller;
    my @commands = get_commands($location); #unpack list of commands to run from caller;
    foreach my $command (@commands) { #look at each command in the list passed in;
        given ($command) { #begin case statement for commands;

            when (/synergy/) { #if specified command is 'synergy';
                my $target_host = $config->{"$location.synergy"};    
                logger("Starting synergyc...");
                my $synergy_command = "/usr/bin/synergyc $target_host";
                my $username = 'conor';
#                system('/usr/bin/synergyc', $target_host); #start synergyc, connecting to host;
                run_as_user($username, $synergy_command);
            }

            when (/monitor/) { #if specified command is 'monitor';
                system("monitor_setup.pl");
                logger("TESTING MONITOR ACTION NOW");
            }

            when (/netmount/) { #if specified command is 'netmount';
            }

            when (/custom/) { #if user has specified command in conf file;
#                my $custom_command = $config->[1]->{$location}->{commands}->{custom};    
                my $custom_command = $config->{"$location.custom"};    
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
1;
