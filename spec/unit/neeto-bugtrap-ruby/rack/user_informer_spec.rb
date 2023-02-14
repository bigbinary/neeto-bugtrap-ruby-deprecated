# frozen_string_literal: true

require 'neeto-bugtrap-ruby/rack/user_informer'
require 'neeto-bugtrap-ruby/config'

describe NeetoBugtrap::Rack::UserInformer do
  let(:agent) { NeetoBugtrap::Agent.new }
  let(:config) { agent.config }

  it 'modifies output if there is a neetobugtrap id' do
    main_app = lambda do |env|
      env['neetobugtrap.error_id'] = 1
      [200, {}, ['<!-- NEETOBUGTRAP ERROR -->']]
    end
    informer_app = NeetoBugtrap::Rack::UserInformer.new(main_app, agent)

    result = informer_app.call({})

    expect(result[2][0]).to eq 'NeetoBugtrap Error 1'
    expect(result[1]['Content-Length'].to_i).to eq 19
  end

  it 'does not modify output if there is no neetobugtrap id' do
    main_app = lambda do |_env|
      [200, {}, ['<!-- NEETOBUGTRAP ERROR -->']]
    end
    informer_app = NeetoBugtrap::Rack::UserInformer.new(main_app, agent)

    result = informer_app.call({})

    expect(result[2][0]).to eq '<!-- NEETOBUGTRAP ERROR -->'
  end
end
