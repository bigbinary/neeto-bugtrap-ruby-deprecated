require 'sinatra/base'

class SinatraApp < Sinatra::Base
  set :show_exceptions, true
  set :neetobugtrap_api_key, 'gem testing'

  get '/runtime_error' do
    raise 'exception raised from test Sinatra app in neeto-bugtrap-ruby gem test suite'
  end

  get '/' do
    'This is a test Sinatra app used by the neeto-bugtrap-ruby gem test suite.'
  end
end
