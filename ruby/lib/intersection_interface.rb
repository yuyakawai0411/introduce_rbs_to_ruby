module FooModule
  def foo
    "foo"
  end
end

module BarModule
  def bar
    "bar"
  end
end

class Foo
  include FooModule
end

class Bar
  include BarModule
end

class FooBar
  include FooModule
  include BarModule
end

def put_foo(object)
  puts object.foo
end

def put_bar(object)
  puts object.bar
end

def put_foo_bar(object)
  puts object.foo
  puts object.bar
end

foo = Foo.new
bar = Bar.new
foo_bar = FooBar.new

put_foo(foo)
put_bar(bar)
put_foo_bar(foo_bar)
put_foo_or_bar(foo_bar)
