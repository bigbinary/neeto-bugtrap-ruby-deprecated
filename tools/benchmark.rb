# frozen_string_literal: true

# Public: Standalone benchmark, useful for profiling JRuby.
#
# Examples:
#
#   To profile object allocations using the JVM's built-in profiler:
#
#     bundle exec jruby -J-Xrunhprof spec/benchmark.rb

require 'neeto-bugtrap-ruby'
require 'benchmark'

benchmark = Benchmark.measure do
  if NeetoBugtrap.start({ api_key: 'bugtraps', backend: 'null' })
    1000.times do
      NeetoBugtrap.notify(error_class: 'RubyProf',
                          error_message: 'Profiling NeetoBugtrap -- this should never actually be reported.')
    end
  end
end

puts benchmark
