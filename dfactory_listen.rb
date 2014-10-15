#!/usr/bin/env ruby

require 'bundler'
Bundler.require(:default)

listen_directory = ARGV[0] || "/home/datafactory"
FIXTURE_PATH = "/webhooks/data_factory/fixture"
DOMAINS = ["http://golazzos.com", "http://golazzos.ngrok.com", "http://qa.golazzos.com", "http://build.golazzos.com"]

begin
  listener = Listen.to(listen_directory) do |modified, added, removed|
    files = modified.concat(added).select{|f| f.include? "fixture"}.uniq
    DOMAINS.each do |domain|
      url = domain + FIXTURE_PATH
      files.each do |file|
        # Typhoeus.post(url, body: {fixture: File.open(file, "r")})
        Typhoeus.post(url, body: {fixture: File.basename(file)})
      end
    end
  end
  listener.start
  sleep
rescue => err
  puts err
end
