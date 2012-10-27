#!/usr/bin/perl
use strict;
use warnings;

sub main {
    my $v = 0;
    my $p = 0;
    for (0 .. 100) {
        print "V: $v P: $p\n";
        my $left = $_ < 10;
        my $right = $_ > 50 && $_ < 70;
        $v -= 2 if $left;
        $v += 2 if $right;
        $v += 1 if $v < 0;
        $v -= 1 if $v > 0;
        $v = 8 if $v > 8;
        $v = -8 if $v < -8;
        $p += $v;
    }
}

main();
