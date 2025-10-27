# Factory Pattern Example
#
# Problem: We need to create objects without having to specify the exact class of the object.
# Solution: Use a generic base class where the "which class" decision is made in a subclass.

class Animal
  def initialize(name)
    @name = name
  end

  def speak
    raise "Subclass must implement"
  end

  def eat
    puts "#{@name} is eating"
  end

  def sleep
    puts "#{@name} is sleeping"
  end
end

class Duck < Animal
  def speak
    puts "#{@name} says Quack!"
  end
end

class Frog < Animal
  def speak
    puts "#{@name} says Croak!"
  end
end

class Pond
  def initialize(number_animals)
    @animals = number_animals.times.inject([]) do |animals, i|
      animals << new_animal("Animal#{i}")
      animals
    end
  end

  def simulate_one_day
    @animals.each {|animal| animal.speak}
    @animals.each {|animal| animal.eat}
    @animals.each {|animal| animal.sleep}
  end

  # This method should be implemented by subclasses
  def new_animal(name)
    raise "Subclass must implement new_animal"
  end
end

class DuckPond < Pond
  def new_animal(name)
    Duck.new(name)
  end
end

class FrogPond < Pond
  def new_animal(name)
    Frog.new(name)
  end
end

# Usage example
if __FILE__ == $0
  puts "Duck pond simulation:"
  duck_pond = DuckPond.new(3)
  duck_pond.simulate_one_day
  
  puts "\nFrog pond simulation:"
  frog_pond = FrogPond.new(3)
  frog_pond.simulate_one_day
end
