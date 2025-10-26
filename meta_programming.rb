# Meta-Programming Pattern Example
#
# Problem: We want to gain more flexibility when defining new classes and create custom tailored objects on the fly.
# Solution: Use Ruby's dynamic features like singleton methods, extend, and class_eval.

# Example 1: Singleton methods for custom objects
def new_plant(stem_type, leaf_type)
  plant = Object.new
  
  if stem_type == :fleshy
    def plant.stem
      'fleshy'
    end
  else
    def plant.stem
      'woody'
    end
  end
  
  if leaf_type == :broad
    def plant.leaf
      'broad'
    end
  else
    def plant.leaf
      'needle'
    end
  end
  
  plant
end

# Example 2: Using extend with modules
module Carnivore
  def diet
    'eats meat'
  end
  
  def hunt
    'hunts for prey'
  end
end

module Herbivore
  def diet
    'eats plants'
  end
  
  def graze
    'grazes peacefully'
  end
end

module Diurnal
  def active_time
    'active during day'
  end
end

module Nocturnal
  def active_time
    'active during night'
  end
end

def new_animal(diet, awake)
  animal = Object.new
  
  if diet == :meat
    animal.extend(Carnivore)
  else
    animal.extend(Herbivore)
  end
  
  if awake == :day
    animal.extend(Diurnal)
  else
    animal.extend(Nocturnal)
  end
  
  animal
end

# Example 3: Meta-programming with class_eval for composite pattern
class CompositeBase
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def self.member_of(composite_name)
    code = %Q{
      attr_accessor :parent_#{composite_name}
    }
    class_eval(code)
  end

  def self.composite_of(composite_name)
    member_of composite_name
    code = %Q{
      def sub_#{composite_name}s
        @sub_#{composite_name}s = [] unless @sub_#{composite_name}s
        @sub_#{composite_name}s
      end
      
      def add_sub_#{composite_name}(child)
        return if sub_#{composite_name}s.include?(child)
        sub_#{composite_name}s << child
        child.parent_#{composite_name} = self
      end
      
      def delete_sub_#{composite_name}(child)
        return unless sub_#{composite_name}s.include?(child)
        sub_#{composite_name}s.delete(child)
        child.parent_#{composite_name} = nil
      end
    }
    class_eval(code)
  end
end

# Example classes using the meta-programming features
class Tiger < CompositeBase
  member_of(:population)
  member_of(:classification)
end

class Tree < CompositeBase
  member_of(:population)
  member_of(:classification)
end

class Jungle < CompositeBase
  composite_of(:population)
end

class Species < CompositeBase
  composite_of(:classification)
end

# Usage examples
if __FILE__ == $0
  puts "=== Singleton Methods Example ==="
  plant1 = new_plant(:fleshy, :broad)
  plant2 = new_plant(:woody, :needle)
  puts "Plant 1's stem: #{plant1.stem}, leaf: #{plant1.leaf}"
  puts "Plant 2's stem: #{plant2.stem}, leaf: #{plant2.leaf}"

  puts "\n=== Extend with Modules Example ==="
  lion = new_animal(:meat, :day)
  rabbit = new_animal(:plants, :day)
  owl = new_animal(:meat, :night)
  
  puts "Lion: #{lion.diet}, #{lion.hunt}, #{lion.active_time}"
  puts "Rabbit: #{rabbit.diet}, #{rabbit.graze}, #{rabbit.active_time}"
  puts "Owl: #{owl.diet}, #{owl.hunt}, #{owl.active_time}"

  puts "\n=== Meta-Programming Composite Example ==="
  tony_tiger = Tiger.new('Tony')
  se_jungle = Jungle.new('Southeastern Jungle')
  
  # Add tiger to jungle population
  se_jungle.add_sub_population(tony_tiger)
  
  puts "Tony's parent population: #{tony_tiger.parent_population&.name}"
  puts "Jungle's population count: #{se_jungle.sub_populations.length}"
  
  # Create species classification
  tiger_species = Species.new('Panthera tigris')
  tiger_species.add_sub_classification(tony_tiger)
  
  puts "Tony's parent classification: #{tony_tiger.parent_classification&.name}"
  puts "Species classification count: #{tiger_species.sub_classifications.length}"
end
