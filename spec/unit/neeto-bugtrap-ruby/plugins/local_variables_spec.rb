# frozen_string_literal: true

require 'neeto-bugtrap-ruby/plugins/local_variables'
require 'neeto-bugtrap-ruby/config'

describe 'Local variables integration', order: :defined do
  let(:config) { NeetoBugtrap::Config.new(logger: NULL_LOGGER, debug: true) }

  before do
    NeetoBugtrap::Plugin.instances[:local_variables].reset!
    config[:'exceptions.local_variables'] = config_enabled
  end

  subject { Exception.new }

  context "when binding_of_caller isn't installed", unless: defined?(::BindingOfCaller) do
    let(:config_enabled) { true }

    it "doesn't install extensions" do
      expect(::Exception).not_to receive(:include).with(NeetoBugtrap::Plugins::LocalVariables::ExceptionExtension)
      NeetoBugtrap::Plugin.instances[:local_variables].load!(config)
    end
  end

  context 'when binding_of_caller is installed', if: defined?(::BindingOfCaller) do
    context 'and disabled by configuration' do
      let(:config_enabled) { false }

      it "doesn't install extensions" do
        expect(::Exception).not_to receive(:include).with(NeetoBugtrap::Plugins::LocalVariables::ExceptionExtension)
        NeetoBugtrap::Plugin.instances[:local_variables].load!(config)
      end
    end

    context 'and enabled by configuration' do
      let(:config_enabled) { true }

      it 'installs the extensions' do
        expect(::Exception).to receive(:include).with(NeetoBugtrap::Plugins::LocalVariables::ExceptionExtension)
        NeetoBugtrap::Plugin.instances[:local_variables].load!(config)
      end

      context 'when BetterErrors is detected' do
        before { Object.const_set(:BetterErrors, Class.new) }
        after { Object.send(:remove_const, :BetterErrors) }

        it 'skips extension' do
          expect(::Exception).not_to receive(:include)
          NeetoBugtrap::Plugin.instances[:local_variables].load!(config)
        end

        it 'warns the logger' do
          expect(config.logger).to receive(:warn).with(/better_errors/)
          NeetoBugtrap::Plugin.instances[:local_variables].load!(config)
        end
      end

      describe NeetoBugtrap::Plugins::LocalVariables::ExceptionExtension do
        subject do
          # Test in isolation rather than installing the plugin globally.
          Class.new(StandardError) do |klass|
            klass.send(:include, NeetoBugtrap::Plugins::LocalVariables::ExceptionExtension)
          end.new
        end

        it {
          should respond_to :__neetobugtrap_bindings_stack
        }

        describe '#set_backtrace' do
          context 'call stack does not match current file' do
            it 'changes the bindings stack' do
              expect { subject.set_backtrace(['foo.rb:1']) }.to change(subject, :__neetobugtrap_bindings_stack).from([])
            end
          end

          context 'call stack includes current file' do
            before do
              allow(subject).to receive(:caller).and_return(["#{File.expand_path(
                '../../../../lib/neeto-bugtrap-ruby/plugins/local_variables.rb', __dir__
              )}:1"])
            end

            it 'does not change the bindings stack' do
              expect do
                subject.set_backtrace(['foo.rb:1'])
              end.not_to change(subject, :__neetobugtrap_bindings_stack).from([])
            end
          end

          context 'call stack includes a non-matching line' do
            before do
              allow(subject).to receive(:caller).and_return(['(foo)'])
            end

            it 'skips the non-matching line' do
              expect { subject.set_backtrace(['foo.rb:1']) }.not_to raise_error
            end

            it 'changes the bindings stack' do
              expect { subject.set_backtrace(['foo.rb:1']) }.to change(subject, :__neetobugtrap_bindings_stack).from([])
            end
          end
        end
      end
    end
  end
end
