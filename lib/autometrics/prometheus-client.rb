require 'singleton'
require 'prometheus/client'

module Autometrics
  AUTOMETRICS_PROMETHEUS_REGISTRY = Prometheus::Client.registry

  class PrometheusClient
    include Singleton

    attr_accessor :function_calls_counter, :function_calls_duration

    def initialize
      @function_calls_counter = Prometheus::Client::Counter.new(
        :function_calls_count,
        docstring: 'A counter of function calls',
        labels: [:function, :module]
      )
      AUTOMETRICS_PROMETHEUS_REGISTRY.register(@function_calls_counter)

      @function_calls_duration = Prometheus::Client::Histogram.new(
        :function_calls_duration,
        docstring: 'A histogram of function durations',
        labels: [:function, :module]
      )

      AUTOMETRICS_PROMETHEUS_REGISTRY.register(function_calls_duration)
    end

    def test_get_values(labels)
      # Example labels: { function: :bare_function, module: '' }
      {
        function_calls_counter: function_calls_counter.get(labels: labels),
        function_calls_duration: function_calls_duration.get(labels: labels)
      }
    end
  end
end
