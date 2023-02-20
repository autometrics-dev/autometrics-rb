require 'prometheus/client'

module Autometrics
  AUTOMETRICS_PROMETHEUS_REGISTRY_MODULE = Prometheus::Client.registry

  FUNCTION_CALLS_COUNTER =
    Prometheus::Client::Counter.new(
      :function_calls_count,
      docstring: 'A counter of function calls',
      labels: [:function, :module]
    )

  FUNCTION_DURATION_HIST =
    Prometheus::Client::Histogram.new(
      :function_calls_duration,
      docstring: 'A histogram of function durations',
      labels: [:function, :module]
    )

  def self.included(klass)
    klass.extend(ClassMethods)
    # HACK - turn off autometrics by default
    klass.extend(Module.new do 
      def initialize(*args, &block)
        autometrics(disabled: true)
        super
      end
    end)
  end

  module On
    def self.included(klass)
      klass.extend(ClassMethods)
      # HACK - turn on autometrics here when user includes `On`
      klass.extend(Module.new do 
        def initialize(*args, &block)
          autometrics(disabled: false)
          super
        end
      end)
    end
  end

  module ClassMethods
    def autometrics(**options)
      # Flag to turn off autometrics for this instance
      @autometrics_enabled = !options[:disabled]

      # Deny-list of methods (as symbols) to skip gathering autometrics for
      @autometrics_skip = options[:skip] || []

      # Allow-list of methods (as symbols) to gather metrics for
      only = options[:only]
      if only
        @autometrics_only = if only.is_a?(Array) then only else [only] end
      end

      # TODO - log better warning if `disabled` is true and other options are passed in
      if !@autometrics_enabled && instance_variable_defined?(@autometrics_only)
        p "WARNING: autometrics disabled, but you an 'only' option is configured"
      end
    end

    # Helper function to enable autometrics for all methods in a class
    def autometrics_all
      autometrics(disabled: false)
      unset_instance_variable(:@autometrics_skip)
      unset_instance_variable(:@autometrics_only)
    end

    # Metaprogramming magic to redefine methods as they are added to the class
    def method_added(method_name)
      return unless @autometrics_enabled

      if instance_variable_defined?(:@autometrics_skip) && @autometrics_skip.include?(method_name)
        p "Skipping autometrics for #{method_name} because you told me to skip it"
        return
      end

      if instance_variable_defined?(:@autometrics_only) && !@autometrics_only.include?(method_name)
        p "Skipping autometrics for #{method_name} because it's not in the list of 'only' methods"
        return
      end

      # Temporarily disable this flag so that `define_method` does not go into an infinite loop
      # when we redefine the method below.
      @autometrics_enabled = false

      # Alias the original method so we can reference it later
      original_method_name = "#{method_name}_without_autometrics".to_sym
      alias_method original_method_name, method_name

      # Redefine the original method
      #   NOTE - Only the contents inside define_method's block are executed in the context of the instance.
      define_method(method_name) do |*args, &fn|
        begin
          # TODO - This only gets the name of the class...
          #        What if the class is included in another module or something wonky like that?
          module_name = self.class.name

          labels = {
            function: method_name,
            # TODO - figure out how to get and format the module name properly
            module: module_name
          }

          p "[autometrics::#{method_name}] Incrementing function calls..."
          FUNCTION_CALLS_COUNTER.increment(labels: labels)

          start_time = Time.now
          original_result = send(original_method_name, *args, &fn)
          end_time = Time.now
          elapsed_time = end_time - start_time


          p "[autometrics::#{method_name}] Observing function duration hist..."
          FUNCTION_DURATION_HIST.observe(elapsed_time, labels: labels)

          original_result
        rescue => error
          # TODO - automatically count errors?
          raise error
        end
      end

      # Turn our autometrics flag back on
      @autometrics_enabled = true
    end
  end
end
