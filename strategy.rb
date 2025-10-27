# Strategy Pattern Example
#
# Problem: We need to vary part of an algorithm while avoiding inheritance drawbacks.
# Solution: Use delegation instead of inheritance. Create a family of interchangeable strategy objects.

class Report
  attr_reader :title, :text
  attr_accessor :formatter

  def initialize(formatter)
    @title = 'Monthly Report'
    @text = ['Things are going', 'really, really well.']
    @formatter = formatter
  end

  def output_report
    @formatter.output_report(self)
  end
end

class HTMLFormatter
  def output_report(context)
    puts('<html>')
    puts(' <head>')
    puts("<title>#{context.title}</title>")
    puts(' </head>')
    puts(' <body>')
    context.text.each do |line|
      puts("<p>#{line}</p>")
    end
    puts(' </body>')
    puts('</html>')
  end
end

class PlainTextFormatter
  def output_report(context)
    puts("***** #{context.title} *****")
    context.text.each do |line|
      puts(line)
    end
  end
end

class MarkdownFormatter
  def output_report(context)
    puts("# #{context.title}")
    puts
    context.text.each do |line|
      puts("- #{line}")
    end
  end
end

# Usage example
if __FILE__ == $0
  puts "HTML Format:"
  report = Report.new(HTMLFormatter.new)
  report.output_report

  puts "\nPlain Text Format:"
  report.formatter = PlainTextFormatter.new
  report.output_report

  puts "\nMarkdown Format:"
  report.formatter = MarkdownFormatter.new
  report.output_report
end
