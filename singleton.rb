# Singleton Pattern Example
#
# Problem: We need to have a single instance of a certain class across the whole application.
# Solution: Restrict access to the constructor and hold the single instance as a class variable.

class SimpleLogger
  attr_accessor :level

  ERROR = 1
  WARNING = 2
  INFO = 3
  
  @@instance = nil
  
  def initialize
    @log = File.open("log.txt", "w")
    @level = WARNING
  end

  def self.instance
    @@instance = new unless @@instance
    return @@instance
  end

  def error(msg)
    @log.puts(msg)
    @log.flush
  end

  def warning(msg)
    @log.puts(msg) if @level >= WARNING
    @log.flush
  end

  def info(msg)
    @log.puts(msg) if @level >= INFO
    @log.flush
  end

  def close
    @log.close
  end

  private_class_method :new
end

# Using Ruby's Singleton module
require 'singleton'

class LoggerUsingSingletonModule
  include Singleton

  attr_accessor :level

  ERROR = 1
  WARNING = 2
  INFO = 3

  def initialize
    @log = File.open("log_singleton_module.txt", "w")
    @level = WARNING
  end

  def error(msg)
    @log.puts(msg)
    @log.flush
  end

  def warning(msg)
    @log.puts(msg) if @level >= WARNING
    @log.flush
  end

  def info(msg)
    @log.puts(msg) if @level >= INFO
    @log.flush
  end

  def close
    @log.close
  end
end

# Usage example
if __FILE__ == $0
  # Manual singleton implementation
  logger1 = SimpleLogger.instance
  logger2 = SimpleLogger.instance
  
  puts "logger1 and logger2 are the same instance: #{logger1.object_id == logger2.object_id}"
  
  logger1.info('Computer wins chess game.')
  logger1.warning('Low disk space')
  logger1.error('System crashed!')
  logger1.close

  # Using Singleton module
  logger3 = LoggerUsingSingletonModule.instance
  logger4 = LoggerUsingSingletonModule.instance
  
  puts "logger3 and logger4 are the same instance: #{logger3.object_id == logger4.object_id}"
  
  logger3.info('Application started')
  logger3.close
end
