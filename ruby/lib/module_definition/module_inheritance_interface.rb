module Quux
  def quxx_method
    puts "quxx"
  end
end

class SampleClass
  include Quux  # Quxが足りていないため、型エラーになる
end
