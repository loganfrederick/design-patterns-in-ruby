# Convention Over Configuration Pattern Example
#
# Problem: We want to build an extensible system without carrying the configuration burden.
# Solution: Establish conventions based on class, method and file names, and standard directory layout.

require 'uri'

class Message
  attr_accessor :from, :to, :body

  def initialize(from, to, body)
    @from = from
    @to = URI.parse(to)
    @body = body
  end
end

# Adapter example following naming convention
require 'net/http'

class HttpAdapter
  def send_message(message)
    Net::HTTP.start(message.to.host, message.to.port) do |http|
      http.post(message.to.path, message.body)
    end
  end
end

class FileAdapter
  def send_message(message)
    File.open(message.to.path, 'w') do |file|
      file.write("From: #{message.from}\n")
      file.write("To: #{message.to}\n")
      file.write("Body: #{message.body}\n")
    end
  end
end

class MessageGateway
  def initialize
    load_adapters
  end

  def process_message(message)
    adapter = adapter_for(message)
    adapter.send_message(message)
  end

  def adapter_for(message)
    protocol = message.to.scheme
    adapter_class_name = protocol.capitalize + 'Adapter'
    adapter_class = self.class.const_get(adapter_class_name)
    adapter_class.new
  rescue NameError
    raise "No adapter found for protocol: #{protocol}"
  end

  def load_adapters
    # In a real application, this would load adapters from a directory
    # lib_dir = File.dirname(__FILE__)
    # full_pattern = File.join(lib_dir, 'adapter', '*.rb')
    # Dir.glob(full_pattern).each {|file| require file }
    puts "Loading adapters from adapter directory..."
  end
end

# Authorization following naming convention
class RussolsenDotComAuthorizer
  def russ_dot_olsen_authorized?(message)
    true
  end

  def authorized?(message)
    message.body.size < 2048
  end
end

def worm_case(string)
  tokens = string.split('.')
  tokens.map! {|t| t.downcase}
  tokens.join('_dot_')
end

class AuthorizationManager
  def authorized?(message)
    authorizer = authorizer_for(message)
    user_method = worm_case(message.from) + '_authorized?'
    if authorizer.respond_to?(user_method)
      return authorizer.send(user_method, message)
    end
    authorizer.authorized?(message)
  end

  def authorizer_for(message)
    host = message.to.host.gsub('.', '_dot_')
    authorizer_class_name = host.split('_').map(&:capitalize).join + 'Authorizer'
    self.class.const_get(authorizer_class_name).new
  rescue NameError
    # Default authorizer
    DefaultAuthorizer.new
  end
end

class DefaultAuthorizer
  def authorized?(message)
    true  # Allow all by default
  end
end

# Generator for creating new adapters
class AdapterGenerator
  def self.generate(protocol_name)
    class_name = protocol_name.capitalize + 'Adapter'
    file_name = File.join('adapter', protocol_name + '.rb')

    scaffolding = %Q{
class #{class_name}
  def send_message(message)
    # Code to send the message via #{protocol_name}
    puts "Sending message via #{protocol_name}: \#{message.body}"
  end
end
}

    File.open(file_name, 'w') do |f|
      f.write(scaffolding)
    end
    
    puts "Generated adapter: #{file_name}"
  end
end

# Usage example
if __FILE__ == $0
  # Create messages
  http_message = Message.new('user@example.com', 'http://api.example.com/messages', 'Hello HTTP!')
  file_message = Message.new('user@example.com', 'file:///tmp/message.txt', 'Hello File!')

  # Process messages using convention-based gateway
  gateway = MessageGateway.new
  
  puts "Processing HTTP message:"
  gateway.process_message(http_message)
  
  puts "\nProcessing File message:"
  gateway.process_message(file_message)
  
  # Generate a new adapter
  puts "\nGenerating new adapter:"
  AdapterGenerator.generate('ftp')
end
