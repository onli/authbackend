require 'rubygems'
require 'bundler'

Bundler.require

require './server.rb'
run Letsauth::Backend.new