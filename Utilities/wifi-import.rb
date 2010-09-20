#!/usr/local/bin/ruby
require 'dnssd'
require 'httpclient'

Thread.abort_on_exception = true
trap 'INT' do exit end
trap 'TERM' do exit end

service = nil
url = nil

if ARGV.length > 0 then
	filename = ARGV[0]
else
	puts "Specify a CSV file on the command line."
	exit
end

puts "Waiting for FatWatch to come online..."

DNSSD.browse! '_http._tcp', 'local.' do |b|
	next if not b.flags.add?
	if b.name.start_with?('FatWatch') then
		service = b
		break
	end
end

puts "Found #{service.name}"

DNSSD.resolve! service do |r|
	url = "http://#{r.target}:#{r.port}"
	break
end

puts "Will connect to #{url}"

# send it to app

client = HTTPClient.new

body = {
	'filedata' => File.new(filename, 'r'),
	'encoding' => '4'
}
res = client.post(url + '/upload', body)
puts "Upload response: #{res.status}"

body = {
	'doImport' => 'Import',
	
	'dateFormat' => 'y-MM-dd',
	'weightFormat' => 1,
	'fatFormat' => 0,

	'date' => 1,
	'weight' => 2,
	'fat' => 3,
	'flag0' => 4,
	'flag1' => 5,
	'flag2' => 6,
	'flag3' => 7,
	'note' => 8,
	
	'prep' => 'replace', # or 'none'
}
res = client.post(url + '/process', body)
puts "Import response: #{res.status}"
