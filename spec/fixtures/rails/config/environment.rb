# Load the rails application
require File.expand_path('../application', __FILE__)

# Load honeybadger hooks before initialization.
require 'neeto-bugtrap-ruby'

# Initialize the rails application
RailsApp.initialize!
