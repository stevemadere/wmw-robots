#!/usr/bin/perl
# Copyright 2010, Steve Madere
#

use strict; # require all variables be declared prior to use: e.g: my $v

my %active_commands;
my %return_codes;

sub start_child {
    my($cmd) = @_;
    if (my $child_pid = fork() ) {
        $active_commands{$child_pid} = $cmd;
    } else {
        exec($cmd);
    }
}

sub wait_for_child_to_finish() {
    my $dead_kid = wait();
    if ($dead_kid >=0) {
        my $child_return_code = $?;
        my $cmd = $active_commands{$dead_kid};
        print "    finished: $cmd\n";
        $return_codes{$dead_kid} = $child_return_code;
        if ($child_return_code!=0) {
            warn "command exited with code $child_return_code: ", $cmd, "\n";
        }
        delete $active_commands{$dead_kid};
    } else {
        warn "where the heck did the kids go?\n",
             join(', ', keys(%active_commands)), "\n";
        # all of the active_commands are gone and we never noticed?
        %active_commands = ();
    }
}

my $MAX_CHILDREN = shift || 4;
while (my $cmd = <>) { # read a line of input from stdin into $_
    chomp $cmd;
    while (scalar(keys(%active_commands)) >= $MAX_CHILDREN) {
        wait_for_child_to_finish();
    }
    print "starting: $cmd\n";
    start_child($cmd);
}

while (scalar(keys(%active_commands))> 0 ) { wait_for_child_to_finish(); }

