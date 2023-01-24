require 'ruby-prof'
require 'neeto-bugtrap-ruby'

if NeetoBugtrap.start({:api_key => 'bugtraps', :debug => true, :backend => 'null'})
  RubyProf.start and NeetoBugtrap::Agent.at_exit do
    result = RubyProf.stop
    printer = RubyProf::FlatPrinter.new(result)
    printer.print(STDOUT, {})
  end

  1000.times do
    NeetoBugtrap.notify(error_class: 'RubyProf', error_message: 'Profiling NeetoBugtrap -- this should never actually be reported.')
  end
end
