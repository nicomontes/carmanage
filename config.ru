require 'rubygems'
require 'sinatra'
require 'rack'
require File.expand_path '../app.rb', __FILE__

run MyApp.new
