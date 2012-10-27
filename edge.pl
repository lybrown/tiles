#!/usr/bin/perl
use strict;
use warnings;

my $ramwidth = 64;

sub edge {
    my ($map, $coarse, $scr) = @_;
    my $mappos = int($coarse / 4);
    my $mapfrac = $coarse % 4;
    my $drawpos = $coarse;
    for my $my (0 .. 9) {
	my $tile = $map->[$mappos];
	my $tilepos = $tile * 16 + $mapfrac * 4;
        for my $ty (0 .. 3) {
            $scr->[$drawpos] = $tilepos;
            $drawpos += $ramwidth;
            $tilepos++;
        }
        $mappos += 32;
    }
}

sub main {
    my @map = qw(
	0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 3 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	0 0 0 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	0 0 3 2 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7
	0 0 0 2 0 0 0 0 0 0 5 5 5 0 0 0 0 0 0 0 0 6 6 0 0 0 0 0 0 0 0 7
	0 0 0 2 0 0 0 0 0 0 4 4 4 0 0 0 0 0 0 0 0 6 6 0 0 0 0 0 0 0 0 7
	1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    );

    my @scr = (0) x ($ramwidth * 40);
    my $coarse = 0;
    for (0 .. 50) {
	edge(\@map, $coarse + $_, \@scr);
    }
    for my $y (0 .. 39) {
        printf "%02x ", $scr[$y*$ramwidth+$_] for 0 .. 51;
        print "\n";
    }
}

main();
