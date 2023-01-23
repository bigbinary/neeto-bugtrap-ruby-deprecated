require 'neeto-bugtrap-ruby/backend/null'
require 'neeto-bugtrap-ruby/config'

describe NeetoBugtrap::Backend::Null do
  let(:config) { NeetoBugtrap::Config.new(logger: NULL_LOGGER) }
  let(:logger) { config.logger }

  let(:instance) { described_class.new(config) }

  subject { instance }

  it { should respond_to :notify }

  describe "#notify" do
    subject { instance.notify(:notices, double('Notice')) }

    it { should be_a NeetoBugtrap::Backend::Response }
  end

  describe "#check_in" do
    subject { instance.check_in(10) }

    it { should be_a NeetoBugtrap::Backend::Response }
  end
end
