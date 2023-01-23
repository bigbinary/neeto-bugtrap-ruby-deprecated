require 'neeto-bugtrap-ruby/plugin'
require 'neeto-bugtrap-ruby/backtrace'

module NeetoBugtrap
  module Plugins
    module LocalVariables
      module ExceptionExtension
        def self.included(base)
          base.send(:alias_method, :set_backtrace_without_neetobugtrap, :set_backtrace)
          base.send(:alias_method, :set_backtrace, :set_backtrace_with_neetobugtrap)
        end

        def set_backtrace_with_neetobugtrap(*args, &block)
          if caller.none? { |loc| loc.match(::NeetoBugtrap::Backtrace::Line::INPUT_FORMAT) && Regexp.last_match(1) == __FILE__ }
            @__neetobugtrap_bindings_stack = binding.callers.drop(1)
          end

          set_backtrace_without_neetobugtrap(*args, &block)
        end

        def __neetobugtrap_bindings_stack
          @__neetobugtrap_bindings_stack || []
        end
      end

      Plugin.register do
        requirement { config[:'exceptions.local_variables'] }
        requirement { defined?(::BindingOfCaller) }
        requirement do
          if res = defined?(::BetterErrors)
            logger.warn("The local variables feature is incompatible with the " \
                        "better_errors gem; to remove this warning, set " \
                        "exceptions.local_variables to false for environments " \
                        "which load better_errors.")
          end
          !res
        end
        requirement { !::Exception.included_modules.include?(ExceptionExtension) }

        execution { ::Exception.send(:include, ExceptionExtension) }
      end
    end
  end
end
