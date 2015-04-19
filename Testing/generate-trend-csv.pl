#!/usr/bin/perl
#
# generate-trend-csv.pl
# Copyright 2015 Heroic Software Inc
#
# This file is part of FatWatch.
#
# FatWatch is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# FatWatch is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with FatWatch.  If not, see <http://www.gnu.org/licenses/>.
#

my $t = time(); # start, go 30 days backward

sub format_time {
	my $t = shift;
	my @d = localtime($t);
	my $y = 1900 + $d[5];
	my $m = 1 + $d[4];
	my $d = $d[3];
	return sprintf("%04d-%02d-%02d", $y, $m, $d);
}

# arguments: goal-weight actual change-per-day

my $weight = shift || 100;
my $delta = shift || -0.1;

for (my $n = 0; $n < 90; $n++) {
	my $date = format_time($t);
	print join(',', $date, $weight), "\n";
	$t -= 86400;
	$weight -= $delta;
}
