# frozen_string_literal: true

require 'aruba/rspec'
require 'aruba/api'
require 'fileutils'
require 'logger'
require 'pathname'
require 'rspec/its'
require 'webmock/rspec'

# We don't want this bleeding through in tests. (i.e. from CircleCi)
ENV['RACK_ENV'] = nil
ENV['RAILS_ENV'] = nil

require 'neeto-bugtrap-ruby/ruby'

begin
  require 'i18n'
  I18n.enforce_available_locales = false
rescue LoadError
  nil
end

Dir[File.expand_path('support/**/*.rb', __dir__)].sort.each { |f| require f }

TMP_DIR = Pathname.new(File.expand_path('../tmp', __dir__))
FIXTURES_PATH = Pathname.new(File.expand_path('fixtures', __dir__))
NULL_LOGGER = Logger.new(File::NULL)
NULL_LOGGER.level = Logger::Severity::DEBUG

Aruba.configure do |config|
  t = RUBY_PLATFORM == 'java' ? 120 : 12
  config.working_directory = 'tmp/features'
  config.exit_timeout = t
  config.io_wait_timeout = t
end

RSpec.configure do |config|
  Kernel.srand config.seed

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.alias_example_group_to :feature, type: :feature
  config.alias_example_group_to :scenario

  config.include Aruba::Api, type: :feature
  config.include FeatureHelpers, type: :feature

  config.before(:all, type: :feature) do
    require 'neeto-bugtrap-ruby/cli'
  end

  config.before(:each, type: :feature) do
    set_environment_variable('NEETOBUGTRAP_BACKEND', 'debug')
    set_environment_variable('NEETOBUGTRAP_LOGGING_PATH', 'STDOUT')
  end

  config.include Helpers

  config.before(:all) do
    NeetoBugtrap::Agent.instance = NeetoBugtrap::Agent.new(NeetoBugtrap::Config.new(backend: 'null',
                                                                                    logger: NULL_LOGGER))
  end

  config.after(:each) do
    NeetoBugtrap.clear!
  end

  begin
    # Rack is a soft dependency, and so we want to be able to run the test suite
    # without it.
    require 'rack'
  rescue LoadError
    puts 'Excluding specs which depend on Rack.'
    config.exclude_pattern = 'spec/unit/neeto-bugtrap-ruby/rack/*_spec.rb'
  end

  config.before(:each, framework: :rails) do
    FileUtils.cp_r(FIXTURES_PATH.join('rails'), current_dir)
    cd('rails')
  end

  case ENV['BUNDLE_GEMFILE']
  when /rails/
    config.filter_run_excluding framework: ->(v) { !v || v != :rails }
  when /sinatra/
    config.filter_run_excluding framework: ->(v) { !v || v != :sinatra }
  when /rake/
    config.filter_run_excluding framework: ->(v) { !v || v != :rake }
  else
    config.filter_run_excluding framework: ->(v) { !v || v != :ruby }
  end
end
