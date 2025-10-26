# Observer Pattern Example
#
# Problem: We want a system where every part is aware of the state of the whole.
# Solution: Keep a list of observers and define a clean interface between subject and observers.

class Employee
  attr_reader :name, :title
  attr_reader :salary

  def initialize(name, title, salary)
    @name = name
    @title = title
    @salary = salary
    @observers = []
  end

  def salary=(new_salary)
    @salary = new_salary
    notify_observers
  end

  def add_observer(observer)
    @observers << observer
  end

  def delete_observer(observer)
    @observers.delete(observer)
  end

  def notify_observers
    @observers.each do |observer|
      observer.update(self)
    end
  end
end

class Payroll
  def update(changed_employee)
    puts "Cut a new check for #{changed_employee.name}!"
    puts "Their salary is now #{changed_employee.salary}!"
  end
end

class TaxMan
  def update(changed_employee)
    puts "Send #{changed_employee.name} a new tax bill!"
  end
end

# Using Ruby's built-in Observable module
require 'observer'

class ObservableEmployee
  include Observable

  attr_reader :name, :title
  attr_reader :salary

  def initialize(name, title, salary)
    @name = name
    @title = title
    @salary = salary
  end

  def salary=(new_salary)
    @salary = new_salary
    changed
    notify_observers(self)
  end
end

# Usage example
if __FILE__ == $0
  puts "Manual observer implementation:"
  fred = Employee.new('Fred', 'Crane Operator', 30000.0)

  payroll = Payroll.new
  fred.add_observer(payroll)

  tax_man = TaxMan.new
  fred.add_observer(tax_man)

  fred.salary = 35000.0

  puts "\nUsing Observable module:"
  jane = ObservableEmployee.new('Jane', 'Engineer', 50000.0)
  jane.add_observer(payroll)
  jane.add_observer(tax_man)
  jane.salary = 55000.0
end
