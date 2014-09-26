#!/usr/bin/env ruby

require 'listen'

listen_directory = ARGV[0] || "/home/datafactory"

if File.exists? listen_directory
	listener = Listen.to(listen_directory) do |modified, added, removed|
	  puts "modified absolute path: #{modified}"
	  puts "added absolute path: #{added}"
	  puts "removed absolute path: #{removed}"
	end
	listener.start
	sleep
else
	puts "El directorio #{listen_directory} no existe"
	exit
end
