require 'honeybadger/ruby'

agent = NeetoBugtrapRuby::Agent.new({
  api_key: 'asdf',
  backend: 'debug',
  debug: true,
  logger: Logger.new(STDOUT)
})

agent.notify(error_class: 'CustomNeetoBugtrapRubyException', error_message: 'Test message')

agent.flush

raise 'This should not be reported.'
