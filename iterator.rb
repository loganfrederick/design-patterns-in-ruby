# Iterator Pattern Example
#
# Problem: We have an aggregate object and want to access its collection without exposing its representation.
# Solution: Use external iterators or internal iterators with code blocks.

# External Iterator Example
class ArrayIterator
  def initialize(array)
    @array = array
    @index = 0
  end

  def has_next?
    @index < @array.length
  end

  def item
    @array[@index]
  end

  def next_item
    value = @array[@index]
    @index += 1
    value
  end
end

# Internal Iterator using Enumerable
class Account
  attr_accessor :name, :balance

  def initialize(name, balance)
    @name = name
    @balance = balance
  end

  def <=>(other)
    balance <=> other.balance
  end

  def to_s
    "Account: #{@name}, Balance: $#{@balance}"
  end
end

class Portfolio
  include Enumerable

  def initialize
    @accounts = []
  end

  def each(&block)
    @accounts.each(&block)
  end

  def add_account(account)
    @accounts << account
  end
end

# Usage examples
if __FILE__ == $0
  # External iterator example
  puts "External Iterator Example:"
  array = ['first', 'second', 'third']
  iterator = ArrayIterator.new(array)
  
  while iterator.has_next?
    puts "Current item: #{iterator.next_item}"
  end

  # Internal iterator example
  puts "\nInternal Iterator Example:"
  portfolio = Portfolio.new
  portfolio.add_account(Account.new('Savings', 1000))
  portfolio.add_account(Account.new('Checking', 500))
  portfolio.add_account(Account.new('Investment', 2500))

  puts "All accounts:"
  portfolio.each { |account| puts account }

  puts "\nAccounts with balance > 800:"
  wealthy_accounts = portfolio.select { |account| account.balance > 800 }
  wealthy_accounts.each { |account| puts account }

  puts "\nTotal portfolio value: $#{portfolio.sum(&:balance)}"
  
  puts "\nAny account with balance > 2000? #{portfolio.any? {|account| account.balance > 2000}}"
end
