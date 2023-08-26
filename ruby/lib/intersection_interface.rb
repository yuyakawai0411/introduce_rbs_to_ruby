class Foo
  def foo
    "foo"
  end
end

class BarInheritsFromFoo < Foo
  def bar
    "bar"
  end
end

class FooBar
  def foo
    "foo"
  end

  def bar
    "bar"
  end
end

def put_foo_bar(object)
  puts object.foo
  puts object.bar
end

put_foo_bar(Foo.new)
put_foo_bar(BarInheritsFromFoo.new)
put_foo_bar(FooBar.new)
