#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'
require 'bundler'
require 'logger'
Bundler.require(:default)

CARD_PATH = "/webhooks/data_factory/card"
FIXTURE_PATH = "/webhooks/data_factory/fixture"

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

listener = Listen.to options.directory, only: %r{ficha|fixture} do |modified, added, removed|
  begin
    hydra = Typhoeus::Hydra.new
    files = modified + added
    domains.each do |domain|
      files.each do |file|
        if file =~ /ficha/
          url = domain + CARD_PATH
          params = { card: File.basename(file) }
        elsif file =~ /fixture/
          url = domain + FIXTURE_PATH
          params = { body: File.basename(file) }
        end
        params.merge!(ssl_verifyhost: 2) if url.include?("https")
        request = Typhoeus::Request.new url, method: :post, body: params
        request.on_complete do |response|
          if response.code.to_s =~ /^2/
            logger.info "Send POST to #{url} => #{params} #{response.code}"
          else
            logger.error "Error sending POST to #{url} => #{params} #{response.code}"
          end
        end
        hydra.queue(request)
      end
    end
    hydra.run
  rescue StandardError => e
    logger.error e.message
  end
end

logger.info "=== Notifiying changes in #{options.directory} to #{domains}!!! ==="
listener.start
sleep
