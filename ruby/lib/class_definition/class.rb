class Animal
  attr_reader :name

  def initialize(name)
    @name = name
  end
end

class Dog < Animal
end

class Cat
  attr_reader :name

  def initialize(name)
    @name = name
  end
end

def cry(animal)
  puts "wan"
end

cat = Cat.new("Pochi")
cry(cat)
