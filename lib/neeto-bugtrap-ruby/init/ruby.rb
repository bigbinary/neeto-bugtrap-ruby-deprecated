require 'honeybadger/ruby'

NeetoBugtrapRuby.init!({
  :framework      => :ruby,
  :env            => ENV['RUBY_ENV'] || ENV['RACK_ENV'],
  :'logging.path' => 'STDOUT'
})

NeetoBugtrapRuby.load_plugins!

NeetoBugtrapRuby.install_at_exit_callback
