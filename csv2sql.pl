#!/bin/perl

my $previousTrend = undef;

open(CSVFILE, '<', 'TestData.csv');
open(SQLFILE, '>', 'TestData.sql');
while (my $line = <CSVFILE>) {
	if ($line =~ m{(\d+)/(\d+)/(\d+),(\d+\.\d+),,([01]),(.*)}) {
		$month = $1;
		$day = $2;
		$year = $3;
		$weight = $4;
		$flag = $5;
		$note = $6;
		
		$ewmonth = ($month - 1) + 12*($year - 2001);
		
		$monthday = ($ewmonth << 5) + $day;
		
		if (defined($previousTrend)) {
			$trend = $previousTrend + (0.1 * ($weight - $previousTrend));
		} else {
			$trend = $weight;
		}
		
		print SQLFILE "INSERT INTO weight VALUES ($monthday, $weight, $trend, $flag, \"$note\");\n";
		$previousTrend = $trend;
	} else {
		print "Can't parse: $line";
	}
}
close(SQLFILE);
close(CSVFILE);