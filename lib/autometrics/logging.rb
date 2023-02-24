require 'logger'

module Autometrics
  module Logging
    DEFAULT_LOG_LEVEL = Logger::WARN

    LOG_LEVELS = {
      'warn' => Logger::WARN,
      'info' => Logger::INFO,
      'debug' => Logger::DEBUG
    }

    @@logger = Logger.new(STDERR, level: ENV["LOG_LEVEL"] || DEFAULT_LOG_LEVEL)
    @@logger.formatter = proc do |severity, datetime, progname, msg|
      "[#{severity}] #{msg}\n"
    end

    # When you call module_function within a module, it creates copies of the specified methods as module-level methods.
    module_function

    # @return [Logger]
    def logger
      @@logger
    end
  end
end
