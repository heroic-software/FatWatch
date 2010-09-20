#!/usr/bin/env ruby
require 'optparse'
require 'date'

def update_trend(t,v)
	return v if t.nil?
	return t if v.nil?
	return (0.1 * v) + (0.9 * t)
end

class Generator
	def initialize
		@all_notes = ['note a', 'note b', 'note c']
	end
	
	def random(lo, hi)
		return rand(hi - lo) + lo
	end
	
	def quantum(probability, up = true, down = false)
		if rand(1024) < (1024 * probability) then up else down end
	end
	
	def clamp(value, lo, hi)
		return (value < lo ? lo : (value > hi ? hi : value))
	end
	
	def print_header
	end
	def print_row(row)
		raise "must override print_row"
	end
	def print_footer
	end
	
	def generate(steps, change_per_week)
		weight_increment = change_per_week / 7
		for i in 1..steps
			if quantum(0.99) then # skip today?

				case rand(20)
				when 0
					@rung = clamp(@rung - 1, 1, 48)
				when 1..2
					@rung = clamp(@rung + 1, 1, 48)
				end
				
				note = if quantum(0.1) then
					@all_notes[rand(@all_notes.length)]
				else
					nil
				end
				
				row = {
					:date => @date,
					:flag0 => quantum(0.2, 1, 0),
					:flag1 => quantum(0.5, 1, 0),
					:flag2 => quantum(0.8, 1, 0),
					:flag3 => quantum(0.9, @rung.round, 0),
					:note => note
				}
				
				if quantum(0.9) then # weigh today?
					weight = @weight + (random(-30, 30) / 10.0)
					@weight_trend = update_trend(@weight_trend, weight)
					row[:weight] = weight
					row[:weight_trend] = @weight_trend
					if quantum(0.9) then # also fat today?
						fat = @fat + (random(-10, 10) / 10.0)
						@fat_trend = update_trend(@fat_trend, fat)
						row[:fat] = fat
						row[:fat_trend] = @fat_trend
					end
				end

				print_row row
			end

			# next date
			@date += 1
			@weight += weight_increment
			@fat += weight_increment
		end
	end
	
	def go
		print_header
		plan = [
			# day count, weight change, fat change
			[30, -0.8],
			[60, +0.2],
			[40, -0.8],
			[90, +0.3],
			[40, -1.0],
			[33, -0.5]
		]
		day_count = 0
		plan.each { |a| day_count += a[0] }
		@date = Date.today - day_count
		@weight = 200 # initial weight
		@fat = 0.30 * @weight # 30% initial body fat
		@rung = 20
		plan.each { |a| generate(a[0], a[1]) }
		print_footer
	end
end

class CSVGenerator < Generator
	def print_header
		puts "Date,Weight,Fat,Flag1,Flag2,Flag3,Flag4,Note"
	end
	def print_row(values)
		if values[:fat] then
			fat = 100.0 * (values[:fat] / values[:weight])
		else
			fat = nil
		end
		row = [
			values[:date].strftime('%Y-%m-%d'),
			values[:weight],
			fat,
			values[:flag0],
			values[:flag1],
			values[:flag2],
			values[:flag3],
			values[:note]
		]
		puts row.join(',')
	end
end

def monthday_from_date(date)
	m = ((date.year - 2001) * 12) + (date.month - 1)
	d = date.mday
	return (m << 5) | d
end

def month_from_monthday(md)
	md >> 5
end

def quote(value)
	return "NULL" if value.nil?
	if value.class == String then
		return "NULL" if value.empty?
		return "\"" + value + "\""
	else
		return value
	end
end

class SQL1Generator < Generator
	def print_header
		puts ".read ../Resources/DBCreate1.sql"
	end
	def print_row(values)
		row = [
			monthday_from_date(values[:date]),
			values[:weight],
			values[:trend],
			values[:flag0],
			values[:note]
		]
		puts "INSERT INTO weight VALUES (" + row.map{|x| quote(x)}.join(',') + ");"
	end
end

class SQL2Generator < SQL1Generator
	def print_header
		puts ".read ../Resources/DBCreate2.sql"
	end
end

class SQL3Generator < Generator
	def print_header
		puts ".read ../Resources/DBCreate3.sql"
	end
	def print_month_update(month)
		if (month != @month) then
			if !@month.nil? then
				mrow = [
					@month,
					@last_weight_trend,
					@last_fat_trend
				]
				puts "INSERT INTO months VALUES (" + mrow.map{|x| quote(x)}.join(',') + ");"
			end
			@month = month
		end
	end
	def print_row(values)
		md = monthday_from_date(values[:date])
		print_month_update(month_from_monthday(md))
		@last_weight_trend = values[:weight_trend] if values[:weight_trend]
		@last_fat_trend = values[:fat_trend] if values[:fat_trend]
		row = [
			md,
			values[:weight],
			values[:fat],
			values[:flag0],
			values[:flag1],
			values[:flag2],
			values[:flag3],
			values[:note]
		]
		puts "INSERT INTO days VALUES (" + row.map{|x| quote(x)}.join(',') + ");"
	end
	def print_footer
		print_month_update(@month + 1)
	end
end

generator = nil

options = OptionParser.new do |opts|
	opts.banner = "Usage: make-history.rb [options]"

	generators = {
		:csv => CSVGenerator,
		:sql1 => SQL1Generator,
		:sql2 => SQL2Generator,
		:sql3 => SQL3Generator
	}
	
	opts.on("-f", "--format FORMAT", generators.keys,
			"Output format (csv, sql1, sql2, sql3)") do |format|
		generator = generators[format].new
	end
end.parse!

if generator then
	generator.go
end
