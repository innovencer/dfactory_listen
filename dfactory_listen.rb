#!/usr/bin/env ruby

require 'bundler'
Bundler.require(:default)

listen_directory = ARGV[0] || "/home/datafactory"
FIXTURE_PATH = "/webhooks/data_factory/fixture"
DOMAINS = ["https://golazzos.com", "http://golazzos.ngrok.com", "http://qa.golazzos.com", "http://build.golazzos.com"]

begin
  listener = Listen.to(listen_directory) do |modified, added, removed|
    files = modified.concat(added).select{|f| f.include? "fixture"}.uniq
    DOMAINS.each do |domain|
      url = domain + FIXTURE_PATH
      files.each do |file|
        # Typhoeus.post(url, body: {fixture: File.open(file, "r")})

        params = { body: File.basename(file) }
        params.merge!(ssl_verifyhost: 2) if url.include?("https")

        response = Typhoeus.post(url, params)
        puts "POST to #{url} => #{params} #{response.code}"
      end
    end
  end
  listener.start
  sleep
rescue => err
  puts err
end
