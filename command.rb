# Command Pattern Example
#
# Problem: We want to perform some specific task without knowing how the whole process works.
# Solution: The Command pattern decouples the object that needs to perform a task from the one that knows how to do it.

class SlickButton
  attr_accessor :command

  def initialize(command)
    @command = command
  end

  def on_button_push
    @command.execute if @command
  end
end

class SaveCommand
  def execute
    # Save the current document...
    puts "Saving document..."
  end
end

class Command
  attr_reader :description

  def initialize(description)
    @description = description
  end

  def execute
    raise 'Called abstract method: execute'
  end

  def unexecute
    raise 'Called abstract method: unexecute'
  end
end

class CreateFile < Command
  def initialize(path, contents)
    super "Create file: #{path}"
    @path = path
    @contents = contents
  end

  def execute
    f = File.open(@path, "w")
    f.write(@contents)
    f.close
  end

  def unexecute
    File.delete(@path)
  end
end

class CopyFile < Command
  def initialize(source, target)
    super "Copy #{source} to #{target}"
    @source = source
    @target = target
  end

  def execute
    FileUtils.cp(@source, @target)
  end

  def unexecute
    File.delete(@target)
  end
end

class DeleteFile < Command
  def initialize(path)
    super "Delete file: #{path}"
    @path = path
  end

  def execute
    if File.exist?(@path)
      @contents = File.read(@path)
    end
    File.delete(@path)
  end

  def unexecute
    if @contents
      f = File.open(@path, "w")
      f.write(@contents)
      f.close
    end
  end
end

class CompositeCommand < Command
  def initialize
    @commands = []
  end

  def add_command(cmd)
    @commands << cmd
  end

  def execute
    @commands.each {|cmd| cmd.execute}
  end
end

# Usage examples
if __FILE__ == $0
  save_button = SlickButton.new(SaveCommand.new)
  save_button.on_button_push

  cmds = CompositeCommand.new
  cmds.add_command(CreateFile.new('file1.txt', "hello world\n"))
  cmds.add_command(CopyFile.new('file1.txt', 'file2.txt'))
  cmds.add_command(DeleteFile.new('file1.txt'))
  cmds.execute
end
