require 'forwardable'
require 'neeto-bugtrap-ruby/agent'

# NeetoBugtrap's public API is made up of two parts: the {NeetoBugtrap} singleton
# module, and the {Agent} class. The singleton module delegates its methods to
# a global agent instance, {Agent#instance}; this allows methods to be accessed
# directly, for example when calling +NeetoBugtrap.notify+:
#
#   begin
#     raise 'testing an error report'
#   rescue => err
#     NeetoBugtrap.notify(err)
#   end
#
# Custom agents may also be created by users who want to report to multiple
# NeetoBugtrap projects in the same app (or have fine-grained control over
# configuration), however most users will use the global agent.
#
# @see NeetoBugtrap::Agent
module NeetoBugtrap
  extend Forwardable
  extend self

  # @!macro [attach] def_delegator
  #   @!method $2(...)
  #     Forwards to {$1}.
  #     @see Agent#$2
  def_delegator :'NeetoBugtrap::Agent.instance', :check_in
  def_delegator :'NeetoBugtrap::Agent.instance', :context
  def_delegator :'NeetoBugtrap::Agent.instance', :configure
  def_delegator :'NeetoBugtrap::Agent.instance', :get_context
  def_delegator :'NeetoBugtrap::Agent.instance', :flush
  def_delegator :'NeetoBugtrap::Agent.instance', :stop
  def_delegator :'NeetoBugtrap::Agent.instance', :exception_filter
  def_delegator :'NeetoBugtrap::Agent.instance', :exception_fingerprint
  def_delegator :'NeetoBugtrap::Agent.instance', :backtrace_filter
  def_delegator :'NeetoBugtrap::Agent.instance', :add_breadcrumb
  def_delegator :'NeetoBugtrap::Agent.instance', :breadcrumbs
  def_delegator :'NeetoBugtrap::Agent.instance', :clear!
  def_delegator :'NeetoBugtrap::Agent.instance', :track_deployment

  # @!macro [attach] def_delegator
  #   @!method $2(...)
  #     @api private
  #     Forwards to {$1}.
  #     @see Agent#$2
  def_delegator :'NeetoBugtrap::Agent.instance', :config
  def_delegator :'NeetoBugtrap::Agent.instance', :init!
  def_delegator :'NeetoBugtrap::Agent.instance', :with_rack_env

  # @!method notify(...)
  # Forwards to {Agent.instance}.
  # @see Agent#notify
  def notify(exception_or_opts, opts = {})
    # Note this is defined directly (instead of via forwardable) so that
    # generated stack traces work as expected.
    Agent.instance.notify(exception_or_opts, opts)
  end

  # @api private
  def load_plugins!
    Dir[File.expand_path('../plugins/*.rb', __FILE__)].each do |plugin|
      require plugin
    end
    Plugin.load!(self.config)
  end

  # @api private
  def install_at_exit_callback
    at_exit do
      if $! && !ignored_exception?($!) && NeetoBugtrap.config[:'exceptions.notify_at_exit']
        NeetoBugtrap.notify($!, component: 'at_exit', sync: true)
      end

      NeetoBugtrap.stop if NeetoBugtrap.config[:'send_data_at_exit']
    end
  end

  # @deprecated
  def start(config = {})
    raise NoMethodError, <<-WARNING
`NeetoBugtrap.start` is no longer necessary and has been removed.

  Use `NeetoBugtrap.configure` to explicitly configure the agent from Ruby moving forward:

  NeetoBugtrap.configure do |config|
    config.api_key = 'project api key'
    config.exceptions.ignore += [CustomError]
  end
WARNING
  end

  private
  # @api private
  def ignored_exception?(exception)
    exception.is_a?(SystemExit) ||
      ( exception.is_a?(SignalException) &&
         ( (exception.respond_to?(:signm) && exception.signm == "SIGTERM") ||
          # jruby has a missing #signm implementation
          ["TERM", "SIGTERM"].include?(exception.to_s) )
    )
  end
end
