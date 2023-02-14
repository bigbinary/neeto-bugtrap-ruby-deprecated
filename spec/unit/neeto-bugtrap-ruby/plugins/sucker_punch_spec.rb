# frozen_string_literal: true

require 'neeto-bugtrap-ruby/plugins/sucker_punch'
require 'neeto-bugtrap-ruby/config'

describe 'SuckerPunch Dependency' do
  let(:config) { NeetoBugtrap::Config.new(logger: NULL_LOGGER, debug: true) }

  before do
    NeetoBugtrap::Plugin.instances[:sucker_punch].reset!
  end

  context 'when sucker_punch is not installed' do
    it 'fails quietly' do
      expect { NeetoBugtrap::Plugin.instances[:sucker_punch].load!(config) }.not_to raise_error
    end
  end

  context 'when sucker_punch is installed' do
    let(:shim) do
      Class.new do
        class << self
          attr_writer :exception_handler
        end
      end
    end

    it 'configures sucker_punch' do
      Object.const_set(:SuckerPunch, shim)
      expect(::SuckerPunch).to receive(:exception_handler=)
      NeetoBugtrap::Plugin.instances[:sucker_punch].load!(config)
    end
  end
end
