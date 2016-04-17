#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'
require 'bundler'
require 'logger'
Bundler.require(:default)

FIXTURE_PATH = "/webhooks/data_factory/ficha"

def get_domains(options)
  domains = %w(https://golazzos.com https://build.golazzos.com http://golazzos.ngrok.io)
  domains = %w(http://localhost:3000) if options.local
  domains = [options.vm_host] if options.vm_host
  domains
end

options = OpenStruct.new(directory: '/home/datafactory/xml/es')
OptionParser.new do |opts|
  opts.banner = "Usage: dfactory_listen [options]"

  opts.on("-d", "--directory=DIR", "Directory to listen") do |dir|
    options.directory = dir
  end

  opts.on("-l", "--local", "For local use") do
    options.local = true
  end

  opts.on("-vm_host", "--vm_host=VM_HOST", "Use with the virtual machine") do |vm_host|
    options.vm_host = vm_host
  end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end.parse!

log_path = File.join File.dirname(__FILE__), 'logs', 'log'
logger = Logger.new log_path, 'daily'
domains = get_domains options
listener = Listen.to options.directory do |modified, added, removed|
  files = modified.select{|f| f.include? "ficha"}.uniq
  domains.each do |domain|
    url = domain + FIXTURE_PATH
    files.each do |file|
      params = { ficha: File.basename(file) }
      params.merge!(ssl_verifyhost: 2) if url.include?("https")

      begin
        response = Typhoeus.post(url, body: params)
        logger.info "POST to #{url} => #{params} #{response.code}"
      rescue StandardError => e
        logger.error e.message
      end
    end
  end
end

logger.info "=== dfactory_listen listening to changes in #{options.directory}!!! ==="
listener.start
sleep
