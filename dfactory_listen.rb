#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'
require 'bundler'
Bundler.require(:default)

options = OpenStruct.new(directory: '/home/datafactory/xml/es')

OptionParser.new do |opts|
  opts.banner = "Usage: dfactory_listen [options]"

  opts.on("-d", "--directory=DIR", "Directory to listen") do |dir|
    options.directory = dir
  end

  opts.on("-l", "--local", "For local use") do
    options.local = true
  end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end.parse!

listen_directory = options.directory
FIXTURE_PATH = "/webhooks/data_factory/ficha"

if options.local
  DOMAINS = ["http://localhost:3000"]
else
  DOMAINS = ["https://golazzos.com", "http://golazzos.ngrok.com",
             "http://qa.golazzos.com", "http://build.golazzos.com", "http://pdn.golazzos.com.mx"]
end

begin
  listener = Listen.to(listen_directory) do |modified, added, removed|
    files = modified.concat(added).select{|f| f.include? "ficha"}.uniq
    DOMAINS.each do |domain|
      url = domain + FIXTURE_PATH
      files.each do |file|
        params = { ficha: File.basename(file) }
        params.merge!(ssl_verifyhost: 2) if url.include?("https")

        response = Typhoeus.post(url, body: params)
        puts "POST to #{url} => #{params} #{response.code}"
      end
    end
  end
  listener.start
  sleep
rescue => err
  puts err
end
