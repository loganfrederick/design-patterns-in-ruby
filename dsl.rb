# Domain-Specific Language (DSL) Pattern Example
#
# Problem: We want to build a convenient syntax for solving problems of a specific domain.
# Solution: Build data structures and top-level methods that create a new language on top of Ruby.

require 'singleton'
require 'fileutils'

# Data structures for the backup DSL
class Backup
  include Singleton

  attr_accessor :backup_directory, :interval
  attr_reader :data_sources
  
  def initialize
    @data_sources = []
    @backup_directory = '/backup'
    @interval = 60
  end

  def backup_files
    this_backup_dir = Time.new.ctime.tr(' :','_')
    this_backup_path = File.join(backup_directory, this_backup_dir)
    @data_sources.each {|source| source.backup(this_backup_path)}
  end

  def run
    while true
      backup_files
      sleep(@interval * 60)
    end
  end
end

class DataSource
  attr_reader :directory, :finder_expression

  def initialize(directory, finder_expression)
    @directory = directory
    @finder_expression = finder_expression
  end

  def backup(backup_directory)
    files = @finder_expression.evaluate(@directory)
    files.each do |file|
      backup_file(file, backup_directory)
    end
  end

  def backup_file(path, backup_directory)
    copy_path = File.join(backup_directory, path)
    FileUtils.mkdir_p(File.dirname(copy_path))
    FileUtils.cp(path, copy_path)
  end
end

# Finder expressions for the DSL
class FinderExpression
  def evaluate(directory)
    []
  end

  def &(other)
    And.new(self, other)
  end

  def |(other)
    Or.new(self, other)
  end
end

class All < FinderExpression
  def evaluate(directory)
    results = []
    Find.find(directory) do |p|
      next unless File.file?(p)
      results << p
    end
    results
  rescue Errno::ENOENT
    []
  end
end

class FileName < FinderExpression
  def initialize(pattern)
    @pattern = pattern
  end

  def evaluate(directory)
    results = []
    Find.find(directory) do |p|
      next unless File.file?(p)
      name = File.basename(p)
      results << p if File.fnmatch(@pattern, name)
    end
    results
  rescue Errno::ENOENT
    []
  end
end

class And < FinderExpression
  def initialize(left, right)
    @left = left
    @right = right
  end

  def evaluate(directory)
    left_results = @left.evaluate(directory)
    right_results = @right.evaluate(directory)
    left_results & right_results
  end
end

class Or < FinderExpression
  def initialize(left, right)
    @left = left
    @right = right
  end

  def evaluate(directory)
    left_results = @left.evaluate(directory)
    right_results = @right.evaluate(directory)
    (left_results + right_results).uniq
  end
end

class Except < FinderExpression
  def initialize(expression)
    @expression = expression
  end

  def evaluate(directory)
    all_files = All.new.evaluate(directory)
    excluded_files = @expression.evaluate(directory)
    all_files - excluded_files
  end
end

# DSL Methods - these create the actual DSL syntax
def backup(dir, find_expression=All.new)
  Backup.instance.data_sources << DataSource.new(dir, find_expression)
end

def to(backup_directory)
  Backup.instance.backup_directory = backup_directory
end

def interval(minutes)
  Backup.instance.interval = minutes
end

# Helper methods for creating finder expressions
def file_name(pattern)
  FileName.new(pattern)
end

def except(expression)
  Except.new(expression)
end

# Usage example and DSL program
if __FILE__ == $0
  # This is how the DSL would be used:
  
  backup '/home/user/documents'
  
  backup '/home/user/music', file_name('*.mp3') & file_name('*.wav')
  
  backup '/home/user/images', except(file_name('*.tmp'))
  
  to '/external_drive/backups'
  
  interval 60
  
  # Run the backup (in real usage, this would be done by evaluating a separate .pr file)
  puts "Backup configuration loaded:"
  puts "Backup directory: #{Backup.instance.backup_directory}"
  puts "Interval: #{Backup.instance.interval} minutes"
  puts "Data sources: #{Backup.instance.data_sources.length}"
  
  # Simulate a single backup run (instead of infinite loop)
  puts "\nPerforming backup..."
  Backup.instance.backup_files
  puts "Backup completed!"
end
