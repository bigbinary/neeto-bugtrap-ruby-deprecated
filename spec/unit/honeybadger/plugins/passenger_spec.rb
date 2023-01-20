require 'honeybadger/plugins/passenger'
require 'honeybadger/config'

describe "Passenger integration" do
  let(:config) { NeetoBugtrapRuby::Config.new(logger: NULL_LOGGER, debug: true) }

  before do
    NeetoBugtrapRuby::Plugin.instances[:passenger].reset!
    allow(config.logger).to receive(:debug)
  end

  context "when passenger is not installed" do
    it "fails quietly" do
      expect { NeetoBugtrapRuby::Plugin.instances[:passenger].load!(config) }.not_to raise_error
    end
  end

  context "when passenger is installed" do
    let(:shim) { double('PhusionPassenger') }

    before do
      Object.const_set(:PhusionPassenger, shim)
    end
    after { Object.send(:remove_const, :PhusionPassenger) }

    it "logs installation" do
      allow(shim).to receive(:on_event)
      expect(config.logger).to receive(:debug).with(/load plugin name=passenger/i)
      NeetoBugtrapRuby::Plugin.instances[:passenger].load!(config)
    end

    it "installs passenger hooks" do
      expect(shim).to receive(:on_event).with(:starting_worker_process)
      expect(shim).to receive(:on_event).with(:stopping_worker_process)
      NeetoBugtrapRuby::Plugin.instances[:passenger].load!(config)
    end

    context "but not booted" do
      it "skips passenger hooks" do
        # shim will fail if it receives any message
        expect(config.logger).to receive(:debug).with(/skip plugin name=passenger/i)
        NeetoBugtrapRuby::Plugin.instances[:passenger].load!(config)
      end
    end
  end
end
