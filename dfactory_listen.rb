#!/usr/bin/env ruby

require 'bundler'
Bundler.require(:default)

listen_directory = ARGV[0] || "/home/datafactory"
FIXTURE_PATH = "/webhooks/datafactory/fixture"
DOMAINS = ["http://golazzos.com", "http://golazzos.ngrok.com"]

if File.exists? listen_directory
  listener = Listen.to(listen_directory) do |modified, added, removed|
    files = modified.concat(added).select{|f| f.include? "fixture"}
    DOMAINS.each do |domain|
      url = domain + FIXTURE_PATH
      files.each do |file|
        Typhoeus.post(url, body: {fixture: file})
      end
    end
  end
  listener.start
  sleep
else
  puts "El directorio #{listen_directory} no existe"
  exit
end
