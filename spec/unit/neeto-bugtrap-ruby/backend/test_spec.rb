# frozen_string_literal: true

require 'neeto-bugtrap-ruby/backend/test'
require 'neeto-bugtrap-ruby/config'

describe NeetoBugtrap::Backend::Test do
  let(:config) { NeetoBugtrap::Config.new(logger: NULL_LOGGER) }
  let(:logger) { config.logger }

  let(:instance) { described_class.new(config) }

  subject { instance }

  before do
    NeetoBugtrap::Backend::Test.notifications.clear
    NeetoBugtrap::Backend::Test.check_ins.clear
  end

  it { should respond_to :notifications }

  describe '#notifications' do
    it 'sets a default key value rather than just return one' do
      expect(instance.notifications).not_to have_key(:foo)
      expect(instance.notifications[:foo]).to eq []
      expect(instance.notifications).to have_key(:foo)
    end
  end

  describe '#notify' do
    let(:notice) { double('Notice') }

    subject { instance.notify(:notices, double('Notice')) }

    it 'saves notifications for review' do
      expect { instance.notify(:notices, notice) }.to change { instance.notifications[:notices] }.from([]).to([notice])
    end

    it { should be_a NeetoBugtrap::Backend::Response }
  end

  describe '#check_in' do
    it 'saves check_in for review' do
      expect { instance.check_in(10) }.to change { instance.check_ins }.from([]).to([10])
    end

    it 'should return a NeetoBugtrap::Backend::Response' do
      expect(instance.check_in(10)).to be_a NeetoBugtrap::Backend::Response
    end
  end
end
