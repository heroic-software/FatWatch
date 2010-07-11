#!/usr/bin/perl
use Time::Local;

# 10069 imported 377 skipped

sub parse_time {
	my $s = shift;
	if ($s =~ m/^(\d+)-(\d+)-(\d+)$/) {
		return timelocal(0, 0, 0, $3, $2 - 1, $1 - 1900);
	} elsif ($s eq 'today') {
		return time();
	}
	return undef;
}

sub format_time {
	my $t = shift;
	my @d = localtime($t);
	my $y = 1900 + $d[5];
	my $m = 1 + $d[4];
	my $d = $d[3];
	return sprintf("%04d-%02d-%02d", $y, $m, $d);
}

sub it_happens {
	my $p = shift;
	return rand(1) < $p;
}

# parameters

my $begin_time = parse_time('2000-01-01');
my $end_time = parse_time('today');

my $weight_probability = 0.90;
my $weight_min = 100;
my $weight_max = 200;
# weight algorithm: random, random_steps, sine_wave

my $flag_probability = 0.40;
my $note_probability = 0.30;

# note source: text file

my $ONE_DAY = 86400;

for (my $t = $begin_time; $t < $end_time; $t += $ONE_DAY) {

	$date = format_time($t);
	
	if (it_happens($weight_probability)) {
		my $jitter = 1 - rand(2);
		$weight = ($weight_max - $weight_min) * 0.5 * (sin($t) + 1) + $weight_min + $jitter;
		$weight = sprintf("%.1f", $weight);
	} else {
		$weight = undef;
	}
	
	if (it_happens($flag_probability)) {
		$flag = 1;
	} else {
		$flag = 0;
	}
	
	if (it_happens($note_probability)) {
		$note = 'comment';
	} else {
		$note = undef;
	}
	
	print join(',', $date, $weight, $flag, $note), "\n";
}
