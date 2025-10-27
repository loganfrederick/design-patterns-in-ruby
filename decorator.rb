# Decorator Pattern Example
#
# Problem: We need to vary the responsibilities of an object, adding some features.
# Solution: Create decorators that wrap the real object and implement the same interface.

class SimpleWriter
  def initialize(path)
    @file = File.open(path, 'w')
  end

  def write_line(line)
    @file.print(line)
    @file.print("\n")
  end

  def pos
    @file.pos
  end

  def rewind
    @file.rewind
  end

  def close
    @file.close
  end
end

class WriterDecorator
  def initialize(real_writer)
    @real_writer = real_writer
  end

  def write_line(line)
    @real_writer.write_line(line)
  end

  def pos
    @real_writer.pos
  end

  def rewind
    @real_writer.rewind
  end

  def close
    @real_writer.close
  end
end

class NumberingWriter < WriterDecorator
  def initialize(real_writer)
    super(real_writer)
    @line_number = 1
  end

  def write_line(line)
    @real_writer.write_line("#{@line_number}: #{line}")
    @line_number += 1
  end
end

class TimeStampingWriter < WriterDecorator
  def write_line(line)
    @real_writer.write_line("#{Time.new}: #{line}")
  end
end

class CheckSummingWriter < WriterDecorator
  attr_reader :check_sum

  def initialize(real_writer)
    super(real_writer)
    @check_sum = 0
  end

  def write_line(line)
    @check_sum += checksum_for(line)
    @real_writer.write_line("#{line} (checksum: #{@check_sum})")
  end

  private

  def checksum_for(line)
    line.bytes.inject(0) { |sum, byte| sum + byte }
  end
end

# Usage examples
if __FILE__ == $0
  # Simple numbering
  writer = NumberingWriter.new(SimpleWriter.new('final.txt'))
  writer.write_line('Hello out there')
  writer.close

  # Chained decorators
  writer = CheckSummingWriter.new(TimeStampingWriter.new(
              NumberingWriter.new(SimpleWriter.new('final_decorated.txt'))))
  writer.write_line('Hello out there')
  writer.close
end
