require 'sinatra'
require 'neeto-bugtrap-ruby'

GC::Profiler.enable

# class Bugtraps < Sinatra::Application

get '/' do
  'Hello world!'
end

get '/test/failure' do
  fail 'Sinatra has left the building'
end

# end

# Bugtraps.run!
