module Puts
  def puts_wrapper
    puts "puts"
  end
end

class SampleInclude
  # include Puts
end

def puts_method(sample)
	sample.puts_wrapper
end

sample = SampleInclude.new
puts_method(sample)
