require 'neeto-bugtrap-ruby/ruby'

NeetoBugtrap.init!({
  :framework      => :ruby,
  :env            => ENV['RUBY_ENV'] || ENV['RACK_ENV'],
  :'logging.path' => 'STDOUT'
})

NeetoBugtrap.load_plugins!

NeetoBugtrap.install_at_exit_callback
