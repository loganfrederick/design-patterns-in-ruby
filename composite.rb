# Composite Pattern Example
#
# Problem: We need to build a hierarchy of tree objects and want to interact with all them the same way.
# Solution: Create component, leaf and composite classes that implement the same interface.

class Task
  attr_accessor :name, :parent

  def initialize(name)
    @name = name
    @parent = nil
  end

  def get_time_required
    0.0
  end
end

# Leaf classes
class AddDryIngredientsTask < Task
  def initialize
    super('Add dry ingredients')
  end

  def get_time_required
    1.0
  end
end

class AddLiquidsTask < Task
  def initialize
    super('Add liquids')
  end

  def get_time_required
    0.5
  end
end

class MixTask < Task
  def initialize
    super('Mix')
  end

  def get_time_required
    3.0
  end
end

class FillPanTask < Task
  def initialize
    super('Fill pan')
  end

  def get_time_required
    2.0
  end
end

class BakeTask < Task
  def initialize
    super('Bake')
  end

  def get_time_required
    30.0
  end
end

class FrostTask < Task
  def initialize
    super('Frost')
  end

  def get_time_required
    5.0
  end
end

class LickSpoonTask < Task
  def initialize
    super('Lick spoon')
  end

  def get_time_required
    1.0
  end
end

# Composite class
class CompositeTask < Task
  def initialize(name)
    super(name)
    @sub_tasks = []
  end

  def add_sub_task(task)
    @sub_tasks << task
    task.parent = self
  end

  def remove_sub_task(task)
    @sub_tasks.delete(task)
    task.parent = nil
  end

  def get_time_required
    @sub_tasks.inject(0.0) {|time, task| time += task.get_time_required}
  end
end

# Composite tasks
class MakeBatterTask < CompositeTask
  def initialize
    super('Make batter')
    add_sub_task(AddDryIngredientsTask.new)
    add_sub_task(AddLiquidsTask.new)
    add_sub_task(MixTask.new)
  end
end

class MakeCakeTask < CompositeTask
  def initialize
    super('Make cake')
    add_sub_task(MakeBatterTask.new)
    add_sub_task(FillPanTask.new)
    add_sub_task(BakeTask.new)
    add_sub_task(FrostTask.new)
    add_sub_task(LickSpoonTask.new)
  end
end

# Usage example
if __FILE__ == $0
  make_cake = MakeCakeTask.new
  puts "Making a cake will take #{make_cake.get_time_required} minutes"
end
