require 'neeto-bugtrap-ruby/ruby'

RSpec::Matchers.define :define do |expected|
  match do |actual|
    expect(actual.constants).to include(expected)
  end
end

describe NeetoBugtrapRuby do
  it { should be_a Module }
  it { should respond_to :notify }
  it { should respond_to :start }
  it { should respond_to :track_deployment }

  it { should define(:Rack) }

  describe NeetoBugtrapRuby::Rack do
    it { should define(:ErrorNotifier) }
    it { should define(:UserFeedback) }
    it { should define(:UserInformer) }
  end

  it "delegates ::exception_filter to agent config" do
    expect(NeetoBugtrapRuby.config).to receive(:exception_filter)
    NeetoBugtrapRuby.exception_filter {}
  end

  it "delegates ::backtrace_filter to agent config" do
    expect(NeetoBugtrapRuby.config).to receive(:backtrace_filter)
    NeetoBugtrapRuby.backtrace_filter {}
  end

  it "delegates ::exception_fingerprint to agent config" do
    expect(NeetoBugtrapRuby.config).to receive(:exception_fingerprint)
    NeetoBugtrapRuby.exception_fingerprint {}
  end

  it "delegates ::flush to agent instance" do
    expect(NeetoBugtrapRuby::Agent.instance).to receive(:flush)
    NeetoBugtrapRuby.flush
  end

  describe "#context" do
    let(:c) { {foo: :bar} }

    before { described_class.context(c) }

    it "sets the context" do
      described_class.context(c)
    end

    it "merges existing context" do
      described_class.context({bar: :baz})
      expect(described_class.get_context).to eq({foo: :bar, bar: :baz})
    end

    it "gets current context" do
      expect(described_class.get_context).to eq(c)
    end

    it "clears the context" do
      expect { described_class.context.clear! }.to change { described_class.get_context }.from(c).to(nil)
    end
  end

  describe "#notify" do
    let(:config) { NeetoBugtrapRuby::Config.new(api_key:'fake api key', logger: NULL_LOGGER) }
    let(:instance) { NeetoBugtrapRuby::Agent.new(config) }
    let(:worker) { double('NeetoBugtrapRuby::Worker') }

    before do
      allow(NeetoBugtrapRuby::Agent).to receive(:instance).and_return(instance)
      allow(instance).to receive(:worker).and_return(worker)
    end

    it "creates and send a notice for an exception" do
      exception = build_exception
      notice = stub_notice!(config)

      expect(NeetoBugtrapRuby::Notice).to receive(:new).with(config, hash_including(exception: exception)).and_return(notice)
      expect(worker).to receive(:push).with(notice)

      NeetoBugtrapRuby.notify(exception)
    end

    it "creates and send a notice for a hash" do
      exception = build_exception
      notice = stub_notice!(config)

      expect(NeetoBugtrapRuby::Notice).to receive(:new).with(config, hash_including(error_message: 'uh oh')).and_return(notice)
      expect(worker).to receive(:push).with(notice)

      NeetoBugtrapRuby.notify(error_message: 'uh oh')
    end

    it "does not pass the hash as an exception when sending a notice for it" do
      notice = stub_notice!(config)

      expect(NeetoBugtrapRuby::Notice).to receive(:new).with(anything, hash_excluding(:exception))
      expect(worker).to receive(:push).with(notice)

      NeetoBugtrapRuby.notify(error_message: 'uh oh')
    end

    it "creates and sends a notice for an exception and hash" do
      exception = build_exception
      notice = stub_notice!(config)
      notice_args = { error_message: 'uh oh' }

      expect(NeetoBugtrapRuby::Notice).to receive(:new).with(config, hash_including(notice_args.merge(exception: exception))).and_return(notice)
      expect(worker).to receive(:push).with(notice)

      NeetoBugtrapRuby.notify(exception, notice_args)
    end

    it "sends a notice with a string" do
      notice = stub_notice!(config)

      expect(NeetoBugtrapRuby::Notice).to receive(:new).with(config, hash_including(error_message: 'the test message')).and_return(notice)
      expect(worker).to receive(:push).with(notice)

      NeetoBugtrapRuby.notify('the test message')
    end

    it "sends a notice with any arbitrary object" do
      notice = stub_notice!(config)

      expect(NeetoBugtrapRuby::Notice).to receive(:new).with(config, hash_including(error_message: 'the test message')).and_return(notice)
      expect(worker).to receive(:push).with(notice)

      NeetoBugtrapRuby.notify(double(to_s: 'the test message'))
    end

    it "generates a backtrace excluding the singleton" do
      expect(instance.worker).to receive(:push) do |notice|
        expect(notice.backtrace.to_a[0]).to match('lib/neeto-bugtrap-ruby/agent.rb')
      end

      NeetoBugtrapRuby.notify(error_message: 'testing backtrace generation')
    end

    it "does not deliver an ignored exception when notifying implicitly" do
      exception = build_exception
      notice = stub_notice!(config)
      allow(notice).to receive(:ignore?).and_return(true)

      expect(worker).not_to receive(:push)

      NeetoBugtrapRuby.notify(exception)
    end

    it "does not deliver a halted notice when notifying implicitly" do
      exception = build_exception
      notice = stub_notice!(config)
      allow(notice).to receive(:halted?).and_return(true)

      expect(worker).not_to receive(:push)

      NeetoBugtrapRuby.notify(exception)
    end

    it "does not deliver a halted notice when notifying implicitly with :force option" do
      exception = build_exception
      notice = stub_notice!(config)
      allow(notice).to receive(:halted?).and_return(true)

      expect(worker).not_to receive(:push)

      NeetoBugtrapRuby.notify(exception, force: true)
    end

    it "delivers an ignored exception when notifying implicitly with :force option" do
      exception = build_exception
      notice = stub_notice!(config)
      allow(notice).to receive(:ignore?).and_return(true)

      expect(worker).to receive(:push)

      NeetoBugtrapRuby.notify(exception, force: true)
    end

    it "passes config to created notices" do
      exception = build_exception
      config_opts = { 'one' => 'two', 'three' => 'four' }

      notice = stub_notice(config)

      allow(worker).to receive(:push)
      expect(NeetoBugtrapRuby::Notice).to receive(:new).with(config, kind_of(Hash)).and_return(notice)

      NeetoBugtrapRuby.notify(exception)
    end

    context "without minimum options" do
      context "outside development" do
        it "it warns the logger" do
          expect(worker).to receive(:push)
          expect(NeetoBugtrapRuby.config.logger).to receive(:warn).with(/invalid arguments/)
          NeetoBugtrapRuby.notify({})
        end
      end

      context "in development" do
        it "raises an exception" do
          allow(NeetoBugtrapRuby.config).to receive(:dev?).and_return(true)
          expect(worker).not_to receive(:push)
          expect(NeetoBugtrapRuby.config.logger).not_to receive(:warn)
          expect { NeetoBugtrapRuby.notify({}) }.to raise_error(ArgumentError)
        end
      end
    end
  end

  describe "#configure" do
    before do
      NeetoBugtrapRuby.config.set(:api_key, nil)
      NeetoBugtrapRuby.config.set(:'user_informer.enabled', true)
    end

    it "configures the singleton" do
      expect {
        NeetoBugtrapRuby.configure do |config|
          config.api_key = 'test api key'
        end
      }.to change { NeetoBugtrapRuby.config.get(:api_key) }.from(nil).to('test api key')
    end

    it "yields a Ruby config object" do
      NeetoBugtrapRuby.configure do |config|
        expect(config).to be_a(NeetoBugtrapRuby::Config::Ruby)
      end
    end
  end
end
