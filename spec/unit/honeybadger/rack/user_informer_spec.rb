require 'neeto-bugtrap-ruby/rack/user_informer'
require 'neeto-bugtrap-ruby/config'

describe NeetoBugtrapRuby::Rack::UserInformer do
  let(:agent) { NeetoBugtrapRuby::Agent.new }
  let(:config) { agent.config }

  it 'modifies output if there is a honeybadger id' do
    main_app = lambda do |env|
      env['honeybadger.error_id'] = 1
      [200, {}, ["<!-- HONEYBADGER ERROR -->"]]
    end
    informer_app = NeetoBugtrapRuby::Rack::UserInformer.new(main_app, agent)

    result = informer_app.call({})

    expect(result[2][0]).to eq 'NeetoBugtrapRuby Error 1'
    expect(result[1]["Content-Length"].to_i).to eq 19
  end

  it 'does not modify output if there is no honeybadger id' do
    main_app = lambda do |env|
      [200, {}, ["<!-- HONEYBADGER ERROR -->"]]
    end
    informer_app = NeetoBugtrapRuby::Rack::UserInformer.new(main_app, agent)

    result = informer_app.call({})

    expect(result[2][0]).to eq '<!-- HONEYBADGER ERROR -->'
  end
end
