#!/usr/bin/env ruby
#
# csv-from-db.rb
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

require 'rubygems'
require 'sqlite3'

def monthday_to_s(monthday)
	year = 2001 + ((monthday >> 5) / 12)
	month = 1 + ((monthday >> 5) % 12)
	day = (monthday & 0x1f)	
	sprintf "%04d-%02d-%02d", year, month, day
end

def weight_to_s(weight_lbs)
	if weight_lbs.nil? then
		nil
	else
		sprintf('%.1f', weight_lbs * 0.45359237)
	end
end

def flag_to_s(flag)
	if flag.nil? then
		0
	else
		flag
	end
end

def quote(text)
	if text.nil? then
		nil
	elsif /,|"/.match(text) then
		'"' + text.gsub('"', '""') + '"'
	else
		text
	end	
end

puts "Date,Weight,Mark1,Mark2,Mark3,Mark4,Note"

db = SQLite3::Database.new(ARGV[0])
db.execute("SELECT * FROM days ORDER BY monthday ASC") do |row|
	monthday = row[0]
	total_weight = row[1]
	fat_weight = row[2]
	flag0 = row[3]
	flag1 = row[4]
	flag2 = row[5]
	flag3 = row[6]
	note = row[7]
	puts [
		monthday_to_s(monthday),
		weight_to_s(total_weight),
		flag_to_s(flag0),
		flag_to_s(flag1),
		flag_to_s(flag2),
		flag_to_s(flag3),
		quote(note)
	].join(',')	
end
