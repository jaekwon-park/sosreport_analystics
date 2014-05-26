#!/usr/bin/perl

use strict;
use warnings;
use 5.010;
my %time;

for (my $i=0; $i <= 1430 ; $i = $i + 10) {
	my $m = $i % 60;
	my $h = int($i / 60);
	$time{join(':', (map { length($_) == 1 ? '0'.$_ : $_ } $h, $m))} = 0;
}

foreach my $key (sort keys %time) {
	say "$key => $time{$key}";
}
say "".%time;
