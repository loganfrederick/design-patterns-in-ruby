# Interpreter Pattern Example
#
# Problem: We need a specialized language to solve a well defined problem of a known domain.
# Solution: Create an Abstract Syntax Tree (AST) with terminals and nonterminals that can be evaluated.

require 'find'

# Base class for all expressions
class Expression
  # Common expression code
end

# Terminal expressions (leaf nodes)
class All < Expression
  def evaluate(dir)
    results = []
    Find.find(dir) do |p|
      next unless File.file?(p)
      results << p
    end
    results
  rescue Errno::ENOENT
    []
  end
end

class FileName < Expression
  def initialize(pattern)
    @pattern = pattern
  end

  def evaluate(dir)
    results = []
    Find.find(dir) do |p|
      next unless File.file?(p)
      name = File.basename(p)
      results << p if File.fnmatch(@pattern, name)
    end
    results
  rescue Errno::ENOENT
    []
  end
end

class Bigger < Expression
  def initialize(size)
    @size = size
  end

  def evaluate(dir)
    results = []
    Find.find(dir) do |p|
      next unless File.file?(p)
      results << p if File.size(p) > @size
    end
    results
  rescue Errno::ENOENT
    []
  end
end

class Writable < Expression
  def evaluate(dir)
    results = []
    Find.find(dir) do |p|
      next unless File.file?(p)
      results << p if File.writable?(p)
    end
    results
  rescue Errno::ENOENT
    []
  end
end

# Nonterminal expressions (composite nodes)
class Not < Expression
  def initialize(expression)
    @expression = expression
  end

  def evaluate(dir)
    All.new.evaluate(dir) - @expression.evaluate(dir)
  end
end

class Or < Expression
  def initialize(expression1, expression2)
    @expression1 = expression1
    @expression2 = expression2
  end

  def evaluate(dir)
    result1 = @expression1.evaluate(dir)
    result2 = @expression2.evaluate(dir)
    (result1 + result2).sort.uniq
  end
end

class And < Expression
  def initialize(expression1, expression2)
    @expression1 = expression1
    @expression2 = expression2
  end

  def evaluate(dir)
    result1 = @expression1.evaluate(dir)
    result2 = @expression2.evaluate(dir)
    (result1 & result2)
  end
end

# Parser to build expressions from strings (simplified)
class Parser
  def self.parse(query_string)
    # This is a simplified parser - a real implementation would be more complex
    case query_string.downcase
    when 'all'
      All.new
    when /^name\s*=\s*(.+)/
      FileName.new($1.strip.gsub(/['"]/, ''))
    when /^size\s*>\s*(\d+)/
      Bigger.new($1.to_i)
    when 'writable'
      Writable.new
    else
      All.new
    end
  end
end

# Usage example
if __FILE__ == $0
  # Create test directory structure if it doesn't exist
  test_dir = 'test_dir'
  Dir.mkdir(test_dir) unless Dir.exist?(test_dir)
  
  # Create some test files
  File.write(File.join(test_dir, 'document.txt'), 'Hello world')
  File.write(File.join(test_dir, 'music.mp3'), 'Music data' * 100)
  File.write(File.join(test_dir, 'large_file.dat'), 'x' * 2000)
  
  puts "Test directory created with sample files"
  
  # Simple expressions
  puts "\n1. All files:"
  expr_all = All.new
  files = expr_all.evaluate(test_dir)
  files.each { |f| puts "  #{f}" }

  puts "\n2. MP3 files:"
  expr_mp3 = FileName.new('*.mp3')
  mp3_files = expr_mp3.evaluate(test_dir)
  mp3_files.each { |f| puts "  #{f}" }

  puts "\n3. Files bigger than 1024 bytes:"
  expr_big = Bigger.new(1024)
  big_files = expr_big.evaluate(test_dir)
  big_files.each { |f| puts "  #{f} (#{File.size(f)} bytes)" }

  puts "\n4. Files that are NOT writable:"
  expr_not_writable = Not.new(Writable.new)
  readonly_files = expr_not_writable.evaluate(test_dir)
  if readonly_files.empty?
    puts "  All files are writable"
  else
    readonly_files.each { |f| puts "  #{f}" }
  end

  puts "\n5. Big files OR MP3 files:"
  big_or_mp3_expr = Or.new(Bigger.new(1024), FileName.new('*.mp3'))
  big_or_mp3s = big_or_mp3_expr.evaluate(test_dir)
  big_or_mp3s.each { |f| puts "  #{f}" }

  puts "\n6. Complex expression (Big AND MP3 AND NOT Writable):"
  complex_expression = And.new(
                        And.new(Bigger.new(1024), FileName.new('*.mp3')),
                        Not.new(Writable.new))
  complex_results = complex_expression.evaluate(test_dir)
  if complex_results.empty?
    puts "  No files match this complex criteria"
  else
    complex_results.each { |f| puts "  #{f}" }
  end
  
  # Clean up
  FileUtils.rm_rf(test_dir)
  puts "\nTest directory cleaned up"
end
