#!/usr/bin/env ruby

require 'bundler'
Bundler.require(:default)

listen_directory = ARGV[0] || "/home/datafactory/xml/es"
FIXTURE_PATH = "/webhooks/data_factory/fixture"
DOMAINS = %w(https://golazzos.com https://build.golazzos.com http://golazzos.ngrok.io)

begin
  listener = Listen.to(listen_directory) do |modified, added, removed|
    files = modified.concat(added).select{|f| f.include? "fixture"}.uniq
    DOMAINS.each do |domain|
      url = domain + FIXTURE_PATH
      files.each do |file|
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
