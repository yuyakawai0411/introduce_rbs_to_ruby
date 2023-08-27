module Bar
  def bar_method
    puts "bar"
  end
end

module Baz
  def baz_method
    puts "baz"
  end
end

module Foo
  def foo_method
    puts "foo"
  end
end

class SomeClass
  include Bar
  include Foo  # Bazが足りていないため、型エラーになる
end
