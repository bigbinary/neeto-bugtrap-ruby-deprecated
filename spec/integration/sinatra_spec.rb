# frozen_string_literal: true

begin
  require 'sinatra/base'
  require 'rack/test'
  SINATRA_PRESENT = true
rescue LoadError
  SINATRA_PRESENT = false
  puts 'Skipping Sinatra integration specs.'
end

if SINATRA_PRESENT
  require FIXTURES_PATH.join('sinatra', 'app.rb')
  require 'neeto-bugtrap-ruby/init/sinatra'

  describe 'Sinatra integration' do
    include Rack::Test::Methods

    def app
      SinatraApp
    end

    before(:each) do
      NeetoBugtrap.configure do |config|
        config.backend = 'test'
      end
    end

    after(:each) do
      NeetoBugtrap::Backend::Test.notifications[:notices].clear
    end

    it 'reports exceptions' do
      NeetoBugtrap.flush do
        get '/runtime_error'
        expect(last_response.status).to eq(500)
      end

      expect(NeetoBugtrap::Backend::Test.notifications[:notices].size).to eq(1)
    end

    it 'configures the api key from sinatra config' do
      get '/' # Initialize app
      expect(NeetoBugtrap.config.get(:api_key)).to eq('gem testing')
    end
  end
end
