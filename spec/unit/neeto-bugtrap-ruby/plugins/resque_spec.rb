require 'neeto-bugtrap-ruby/plugins/resque'
require 'neeto-bugtrap-ruby/config'
require 'neeto-bugtrap-ruby/agent'

class TestWorker
  extend NeetoBugtrap::Plugins::Resque::Extension
end

describe TestWorker do
  describe "::on_failure_with_neetobugtrap" do
    let(:error) { RuntimeError.new('Failure in NeetoBugtrap resque_spec') }

    shared_examples_for "reports exceptions" do
      specify do
        expect(NeetoBugtrap).to receive(:notify).with(error, hash_including(parameters: {job_arguments: [1, 2, 3]}, sync: true))
        described_class.on_failure_with_neetobugtrap(error, 1, 2, 3)
      end
    end

    shared_examples_for "does not report exceptions" do
      specify do
        expect(NeetoBugtrap).not_to receive(:notify)
        expect {
          described_class.around_perform_with_neetobugtrap(1, 2, 3) do
            fail 'foo'
          end
        }.to raise_error(RuntimeError)
      end
    end

    it_behaves_like "reports exceptions"

    it "clears the context" do
      expect {
        NeetoBugtrap.context(badgers: true)
        described_class.on_failure_with_neetobugtrap(error, 1, 2, 3)
      }.not_to change { NeetoBugtrap::ContextManager.current.get_context }.from(nil)
    end

    describe "with worker not extending Resque::Plugins::Retry" do
      context "when send exceptions on retry enabled" do
        before { ::NeetoBugtrap.config[:'resque.resque_retry.send_exceptions_when_retrying'] = true }
        it_behaves_like "reports exceptions"
      end

      context "when send exceptions on retry disabled" do
        before { ::NeetoBugtrap.config[:'resque.resque_retry.send_exceptions_when_retrying'] = false }
        it_behaves_like "reports exceptions"
      end
    end

    describe "with worker extending Resque::Plugins::Retry" do
      let(:retry_criteria_valid) { false }

      before do
        class TestWorker
          def self.retry_criteria_valid?(e)
          end
        end
        allow(described_class).to receive(:retry_criteria_valid?).
          and_return(retry_criteria_valid)
      end

      context "when send exceptions on retry enabled" do
        before { ::NeetoBugtrap.config[:'resque.resque_retry.send_exceptions_when_retrying'] = true }

        context "with retry criteria invalid" do
          it_behaves_like "reports exceptions"
        end

        context "with retry criteria valid" do
          let(:retry_criteria_valid) { true }
          it_behaves_like "reports exceptions"
        end
      end

      context "when send exceptions on retry disabled" do
        before { ::NeetoBugtrap.config[:'resque.resque_retry.send_exceptions_when_retrying'] = false }

        context "with retry criteria invalid" do
          it_behaves_like "reports exceptions"
        end

        context "with retry criteria valid" do
          let(:retry_criteria_valid) { true }
          it_behaves_like "does not report exceptions"
        end

        context "and retry_criteria_valid? raises exception" do
          it "should report raised error to neetobugtrap" do
            other_error = StandardError.new('stubbed NeetoBugtrap error in retry_criteria_valid?')
            allow(described_class).to receive(:retry_criteria_valid?).and_raise(other_error)
            expect(NeetoBugtrap).to receive(:notify).with(other_error, hash_including(parameters: {job_arguments: [1, 2, 3]}, sync: true))
            described_class.on_failure_with_neetobugtrap(error, 1, 2, 3)
          end
        end

      end
    end
  end

  describe "::around_perform_with_neetobugtrap" do
    it "flushes pending errors before worker dies" do
      expect(NeetoBugtrap).to receive(:flush)

      described_class.around_perform_with_neetobugtrap do
      end
    end

    it "raises exceptions" do
      expect {
        described_class.around_perform_with_neetobugtrap do
          fail 'foo'
        end
      }.to raise_error(RuntimeError, /foo/)
    end
  end

  describe "::after_perform_with_neetobugtrap" do
    it "clears the context" do
      expect {
        NeetoBugtrap.context(badgers: true)
        described_class.after_perform_with_neetobugtrap
      }.not_to change { NeetoBugtrap::ContextManager.current.get_context }.from(nil)
    end
  end
end
