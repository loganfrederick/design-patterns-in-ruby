# Proxy Pattern Example
#
# Problem: We want to have more control over how and when we access a certain object.
# Solution: Create a proxy object that has a reference to the real object and controls access to it.

class BankAccount
  attr_reader :balance

  def initialize(starting_balance=0)
    @balance = starting_balance
  end

  def deposit(amount)
    @balance += amount
  end

  def withdraw(amount)
    @balance -= amount
  end
end

# Protection Proxy - adds a layer of security
require 'etc'

class AccountProtectionProxy
  def initialize(real_account, owner_name)
    @subject = real_account
    @owner_name = owner_name
  end

  def deposit(amount)
    check_access
    return @subject.deposit(amount)
  end

  def withdraw(amount)
    check_access
    return @subject.withdraw(amount)
  end

  def balance
    check_access
    return @subject.balance
  end

  def check_access
    if Etc.getlogin != @owner_name
      raise "Illegal access: #{Etc.getlogin} cannot access account."
    end
  end
end

# Virtual Proxy - delays creation until needed
class VirtualAccountProxy
  def initialize(starting_balance=0)
    @starting_balance = starting_balance
  end

  def deposit(amount)
    s = subject
    return s.deposit(amount)
  end

  def withdraw(amount)
    s = subject
    return s.withdraw(amount)
  end

  def balance
    s = subject
    return s.balance
  end

  def subject
    @subject ||= BankAccount.new(@starting_balance)
  end
end

# Usage example
if __FILE__ == $0
  # Basic bank account
  puts "Basic bank account:"
  account = BankAccount.new(100)
  account.deposit(50)
  puts "Balance: #{account.balance}"
  
  # Protection proxy
  puts "\nProtection proxy:"
  real_account = BankAccount.new(100)
  begin
    # This will work only if run by the correct user
    proxy_account = AccountProtectionProxy.new(real_account, Etc.getlogin)
    proxy_account.deposit(50)
    puts "Protected account balance: #{proxy_account.balance}"
  rescue => e
    puts "Access denied: #{e.message}"
  end
  
  # Virtual proxy
  puts "\nVirtual proxy:"
  virtual_account = VirtualAccountProxy.new(200)
  puts "Virtual account created (real account not yet created)"
  virtual_account.deposit(100)  # This will create the real account
  puts "Virtual account balance: #{virtual_account.balance}"
end
