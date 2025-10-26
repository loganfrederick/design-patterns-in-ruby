# Template Method Pattern Example
#
# Problem: We have a complex bit of code, but somewhere in the middle there is a bit that needs to vary.
# Solution: Build an abstract base class with a skeletal method that calls abstract methods implemented by subclasses.

class Report
  def initialize
    @title = 'Monthly Report'
    @text = ['Things are going', 'really, really well.']
  end

  def output_report
    output_start
    output_head
    output_body_start
    output_body
    output_body_end
    output_end
  end

  def output_body
    @text.each do |line|
      output_line(line)
    end
  end

  def output_start
    raise 'Called abstract method: output_start'
  end

  def output_head
    raise 'Called abstract method: output_head'
  end

  def output_body_start
    raise 'Called abstract method: output_body_start'
  end

  def output_line(line)
    raise 'Called abstract method: output_line'
  end

  def output_body_end
    raise 'Called abstract method: output_body_end'
  end

  def output_end
    raise 'Called abstract method: output_end'
  end
end

class PlainTextReport < Report
  def output_start
    # Nothing needed for plain text
  end

  def output_head
    puts("**** #{@title} ****")
  end

  def output_body_start
    # Nothing needed for plain text
  end

  def output_line(line)
    puts(line)
  end

  def output_body_end
    # Nothing needed for plain text
  end

  def output_end
    # Nothing needed for plain text
  end
end

class HTMLReport < Report
  def output_start
    puts('<html>')
  end

  def output_head
    puts(' <head>')
    puts("<title>#{@title}</title>")
    puts(' </head>')
  end

  def output_body_start
    puts(' <body>')
  end

  def output_line(line)
    puts("<p>#{line}</p>")
  end

  def output_body_end
    puts(' </body>')
  end

  def output_end
    puts('</html>')
  end
end

# Usage example
if __FILE__ == $0
  puts "Plain Text Report:"
  report = PlainTextReport.new
  report.output_report
  
  puts "\nHTML Report:"
  html_report = HTMLReport.new
  html_report.output_report
end
