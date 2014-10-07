#!/usr/bin/env ruby

require 'bundler'
Bundler.require(:default)

Daemons.run('dfactory_listen.rb')
