module Foo
  def foo
    puts "foo"
  end
end

module Bar
  def bar
    puts "bar"
  end
end

class FooBar
  include Bar
end
