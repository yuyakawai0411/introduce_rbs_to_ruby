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

class FooBar
  include FooModule
  include BarModule
end

def put_foo_bar(object)
  puts object.foo
  puts object.bar
end

put_foo_bar(Foo.new) # fooメソッドしか持っていないため型エラー
put_foo_bar(FooBar.new) # fooもbarメソッドも持っているためOK