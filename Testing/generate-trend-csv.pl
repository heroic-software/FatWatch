#!/usr/bin/perl
# generate CSV files for trend test

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
