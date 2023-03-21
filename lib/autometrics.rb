require 'prometheus/client'

require_relative 'autometrics/prometheus-client'
require_relative 'autometrics/logging'

# Module for adding autometrics functionality to a class
module Autometrics
  PROMETHEUS = Autometrics::PrometheusClient.instance

  # Add necessary autometrics methods and state when we're included in a class
  def self.included(klass)
    klass.extend(ClassMethods)
    # HACK - turns off autometrics by default
    klass.extend(Module.new do 
      def initialize(*args, &block)
        super
        autometrics(disabled: true)
      end
    end)
  end

  # Module that automatically turns on autometrics when included
  # INVESTIGATE - turn this into the pattern that allows you to pass arguments to the included method
  module On
    def self.included(klass)
      klass.extend(ClassMethods)
      # HACK - turns on autometrics here when user includes `On`
      klass.extend(Module.new do 
        def initialize(*args, &block)
          super
          autometrics(disabled: false)
        end
      end)
    end
  end

  module ClassMethods
    def autometrics(**options)
      # Flag to turn off autometrics for this instance
      @autometrics_enabled = !options[:disabled]

      # Allow-list of methods (as symbols) for which we'll gather metrics
      only = options[:only]
      if only
        @autometrics_only = if only.is_a?(Array) then only else [only] end
      end

      # Deny-list of methods (as symbols) to skip gathering autometrics for
      @autometrics_skip = options[:skip] || []
      # Do not gather metrics for the `initialize` method by default
      @autometrics_skip_initialize = options[:skip_initialize] || true
      # INVESTIGATE - add `skip_private_methods` option?
      @autometrics_skip << :initialize if @autometrics_skip_initialize
        
      # TODO - log clearer warning if `disabled` is true and other options are passed in
      should_warn_about_only = !@autometrics_enabled && instance_variable_defined?(@autometrics_only)
      if should_warn_about_only
        Logging.logger.warn "[Autometrics] 'only' option is present, but autometrics is disabled for this class, so no metrics will be gathered for #{@autometrics_only}"
      end
    end

    # Metaprogramming magic to redefine methods as they are added to the class
    def method_added(method_name)
      return unless @autometrics_enabled

      if instance_variable_defined?(:@autometrics_skip) && @autometrics_skip.include?(method_name)
        Logging.logger.debug "Skipping autometrics for #{method_name} because you told me to skip it"
        return
      end

      if instance_variable_defined?(:@autometrics_only) && !@autometrics_only.include?(method_name)
        Logging.logger.debug "Skipping autometrics for #{method_name} because it's not in the list of 'only' methods"
        return
      end

      # HACK - Temporarily disable this flag so that `define_method` does not go into an infinite loop when we redefine the method below
      @autometrics_enabled = false

      # Alias the original method so we can reference it later
      original_method_name = "#{method_name}_without_autometrics".to_sym
      alias_method original_method_name, method_name

      # Redefine the original method and wrap it with autometrics logic
      # NOTE - Only the contents inside define_method's block are executed in the context of the instance.
      define_method(method_name) do |*args, &fn|
        prometheus_client = Autometrics::PrometheusClient.instance
        get_original_result = lambda { send(original_method_name, *args, &fn) }
        module_name = self.class.name
        wrap_with_autometrics(get_original_result, prometheus_client, module_name, method_name)
      end

      # HACK - Turn our autometrics flag back on, since we disabled it above
      @autometrics_enabled = true
    end
  end
end


# NOTE - I think this is the only way to make autometrics work on top-level method calls
#        That is, we need to to have a top-level export like this... but I'm not a Ruby expert, so I'm not sure
#
# Usage: `autometrics def my_method; end`
def autometrics(method_name)
  Autometrics::Logging.logger.debug "[self.autometrics] Adding autometrics to #{method_name}"

  # Get a reference to the method that we're wrapping
  original_method = method(method_name)

  define_method(method_name) do |*args, &fn|
    prometheus_client = Autometrics::PrometheusClient.instance
    get_original_result = lambda { original_method.call(*args, &fn) }
    # TODO - I'm not sure how to get/annotate the module name for a bare function call.
    #        Right now we're just doing an empty string.
    #        That said, in some code bases (like a Sinatra app?), we might consider the filename the module.
    module_name = ""

    wrap_with_autometrics(get_original_result, prometheus_client, module_name, method_name)
  end
end

# Helper method for wrapping a method with autometrics logic
# @param get_result_lambda - a lambda that returns the result of the original method
# @param prometheus_client - an instance of the Prometheus client to record metrics
# @param module_name - the name of the module that the method is defined in
# @param method_name - the name of the method being wrapped
def wrap_with_autometrics(get_result_lambda, prometheus_client, module_name, method_name)
  labels = {
    function: method_name,
    module: module_name
  }

  begin
    Autometrics::Logging.logger.debug "[self.wrap_with_autometrics::#{method_name}] Incrementing function calls with labels: #{labels}"

    # Calculate execution time
    # Use `Process.clock_gettime` instead of `Time.now` for measuring elapsed time
    # See: https://blog.dnsimple.com/2018/03/elapsed-time-with-ruby-the-right-way/
    start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    original_result = get_result_lambda.call
    end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    elapsed_time = end_time - start_time

    Autometrics::Logging.logger.debug "[self.wrap_with_autometrics::#{method_name}] Observing method with labels: #{labels}"

    prometheus_client.function_calls_duration.observe(elapsed_time, labels: labels)

    # TODO - move to constants file
    labels[:result] = "ok"
    prometheus_client.function_calls_counter.increment(labels: labels)

    original_result
  rescue => error
    # TODO - move to constants file
    labels[:result] = "error"
    prometheus_client.function_calls_counter.increment(labels: labels)
    raise error
  end
end