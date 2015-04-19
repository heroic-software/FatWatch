#!/usr/bin/env ruby
#
# validate-db.rb
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

require 'sqlite3'
require 'optparse'

$db = SQLite3::Database.new(ARGV[0])
$epsilon = 1e-4

def update_trend(t,v)
	return v if (t.nil? or t == 0)
	return t if (v.nil? or v == 0)
	return (0.1 * v) + (0.9 * t)
end

def compare_floats(found, expected, what)
	return if (found.nil? or found == 0) and (expected.nil? or expected == 0)
	if (found.nil? or found == 0) then
		puts "#{what}: found nil; expected #{expected}"
	elsif (expected.nil? or expected == 0) then
		puts "#{what}: found #{found}; expected nil"
	else
		delta = (found - expected).abs
		if delta > $epsilon then
			puts "#{what}: found #{found}; expected #{expected}; delta #{delta}"
		end
	end
end

def validate_1
	puts "dataversion: 1"
	# validate trend values
end

def validate_2
	puts "dataversion: 2, same as:"
	validate_1
	# validate trend values
	# ensure no rows with all NULL values
end

def validate_3
	puts "dataversion: 3"
	rows = $db.execute("SELECT MAX(monthday) AS m FROM days GROUP BY monthday >> 5 ORDER BY m")
	lastdays = rows.flatten
	i = 0
	
	trendWeight = nil
	trendFatWeight = nil
	$db.execute("SELECT * FROM days ORDER BY monthday ASC") do |row|
		monthday = row[0]
		trendWeight = update_trend(trendWeight, row[1])
		trendFatWeight = update_trend(trendFatWeight, row[2])
		if monthday == lastdays[i] then
			month = monthday >> 5
			x = $db.get_first_row("SELECT * FROM months WHERE month = ?", month)
			if x.nil? then
				puts "ERROR: months table missing row for month = #{month}" 
			else
				compare_floats(x[1], trendWeight, "Weight trend for month #{month}")
				compare_floats(x[2], trendFatWeight, "Fat trend for month #{month}")
			end
			i += 1
		end
	end
end

dataversion = $db.get_first_value("SELECT value FROM metadata WHERE name = 'dataversion'")

case dataversion
when 1
	validate_1
when 2
	validate_2
when 3
	validate_3
else
	raise "Invalid dataversion (#{dataversion})"
end

