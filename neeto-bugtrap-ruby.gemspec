require File.expand_path('../lib/neeto-bugtrap-ruby/version.rb', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'neeto-bugtrap-ruby'
  s.version     = NeetoBugtrapRuby::VERSION
  s.platform    = Gem::Platform::RUBY
  s.summary     = 'Error reports you can be happy about.'
  s.description = 'Make managing application errors a more pleasant experience.'
  s.metadata = {
    'bug_tracker_uri'   => 'https://github.com/bigbinary/neeto-bugtrap-ruby/issues',
    'changelog_uri'     => 'https://github.com/bigbinary/neeto-bugtrap-ruby/blob/master/CHANGELOG.md',
    'source_code_uri'   => 'https://github.com/bigbinary/neeto-bugtrap-ruby'
  }

  s.required_ruby_version = '>= 2.3.0'

  s.rdoc_options << '--markup=tomdoc'
  s.rdoc_options << '--main=README.md'

  s.files  = Dir['lib/**/*.{rb,erb}']
  s.files += Dir['bin/*']
  s.files += Dir['vendor/**/*.{rb,rake,cap}']
  s.files += Dir['resources/**/*.crt']
  s.files += Dir['*.md']

  s.require_paths = ['lib', 'vendor/capistrano-neetobugtrap/lib']

  s.executables << 'neetobugtrap'
end
