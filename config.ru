require 'sinatra'

require 'sinatra'
require './env' if File.exists?('env.rb')

@config = {} unless @config


#p @config

#set :protection, :except => [:frame_options,:http_origin]

require './app'
run Sinatra::Application
