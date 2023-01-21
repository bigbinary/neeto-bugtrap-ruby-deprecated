require 'neeto-bugtrap-ruby/logging'
require 'neeto-bugtrap-ruby/config'

LOG_SEVERITIES = [:debug, :info, :warn, :error, :fatal].freeze

describe NeetoBugtrapRuby::Logging::Base do
  LOG_SEVERITIES.each do |severity|
    it { should respond_to severity }
  end

  describe "#add" do
    it "requires subclass to define it" do
      expect { subject.add(1, 'snakes!').to raise_error NotImplementedError }
    end
  end
end

describe NeetoBugtrapRuby::Logging::StandardLogger do
  it "injects neetobugtrap as progname" do
    logger_dbl = instance_double(Logger, add: nil)
    logger = described_class.new(logger_dbl)
    expect(logger_dbl).to receive(:add).with(Logger::Severity::INFO, "a message", "neetobugtrap")
    logger.info("a message")
  end
end

describe NeetoBugtrapRuby::Logging::BootLogger.instance do
  LOG_SEVERITIES.each do |severity|
    it { should respond_to severity }

    it "flushes ##{severity} messages to logger" do
      subject.send(severity, :foo)
      logger = double('Logger')
      expect(logger).to receive(:add).with(Logger::Severity.const_get(severity.to_s.upcase), :foo)
      subject.flush(logger)
    end
  end
end

describe NeetoBugtrapRuby::Logging::FormattedLogger do
  let(:logger) { Logger.new(File::NULL) }

  subject { described_class.new(logger) }

  LOG_SEVERITIES.each do |severity|
    it { should respond_to severity }

    it "delegates ##{severity} to configured logger" do
      expect(logger).to receive(:add).with(Logger::Severity.const_get(severity.to_s.upcase), :foo, "neetobugtrap")
      subject.send(severity, :foo)
    end
  end
end

describe NeetoBugtrapRuby::Logging::ConfigLogger do
  let(:config) { NeetoBugtrapRuby::Config.new(debug: true, :'logging.tty_level' => tty_level) }
  let(:logger) { Logger.new(File::NULL) }
  let(:tty_level) { 'ERROR' }

  subject { described_class.new(config, logger) }

  LOG_SEVERITIES.each do |severity|
    it { should respond_to severity }
  end

  context "when not attached to terminal", unless: STDOUT.tty? do
    LOG_SEVERITIES.each do |severity|
      it "delegates ##{severity} to configured logger" do
        # Debug is logged at the info level.
        const = Logger::Severity.const_get((severity == :debug ? :info : severity).to_s.upcase)
        expect(logger).to receive(:add).with(const, :foo, "neetobugtrap")
        subject.send(severity, :foo)
      end
    end
  end

  context "when attached to terminal", if: STDOUT.tty? do
    [:debug, :info, :warn].each do |severity|
      it "suppresses ##{severity} from configured logger" do
        expect(logger).not_to receive(:add)
        subject.send(severity, :foo)
      end
    end

    [:error, :fatal].each do |severity|
      it "delegates ##{severity} to configured logger" do
        expect(logger).to receive(:add).with(Logger::Severity.const_get(severity.to_s.upcase), :foo, "neetobugtrap")
        subject.send(severity, :foo)
      end
    end

    context "and logging.tty is enabled" do
      let(:tty_level) { 'DEBUG' }

      LOG_SEVERITIES.each do |severity|
        it "delegates ##{severity} to configured logger" do
          # Debug is logged at the info level.
          const = Logger::Severity.const_get((severity == :debug ? :info : severity).to_s.upcase)
          expect(logger).to receive(:add).with(const, :foo, "neetobugtrap")
          subject.send(severity, :foo)
        end
      end
    end
  end
end
