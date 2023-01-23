require 'neeto-bugtrap-ruby/ruby'

agent = NeetoBugtrap::Agent.new({
  api_key: 'asdf',
  backend: 'debug',
  debug: true,
  logger: Logger.new(STDOUT)
})

agent.notify(error_class: 'CustomNeetoBugtrapException', error_message: 'Test message')

agent.flush

raise 'This should not be reported.'
