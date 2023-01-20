require 'ruby-prof'
require 'neeto-bugtrap-ruby'

if NeetoBugtrapRuby.start({:api_key => 'badgers', :debug => true, :backend => 'null'})
  RubyProf.start and NeetoBugtrapRuby::Agent.at_exit do
    result = RubyProf.stop
    printer = RubyProf::FlatPrinter.new(result)
    printer.print(STDOUT, {})
  end

  1000.times do
    NeetoBugtrapRuby.notify(error_class: 'RubyProf', error_message: 'Profiling NeetoBugtrapRuby -- this should never actually be reported.')
  end
end
