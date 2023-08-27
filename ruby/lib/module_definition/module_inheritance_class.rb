module Cry
  def cry
    puts "wan wan"
  end
end

class Animal
end

class Human
end

class Dog < Animal
  include Foo
end

class Boy < Human
  include Foo
end
