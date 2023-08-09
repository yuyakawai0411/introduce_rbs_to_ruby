class Cat
  attr_reader :name

  def initialize(name)
    @name = name
  end
end

class Dog
  attr_reader :name

  def initialize(name)
    @name = name
  end
end

def cry(animal)
  puts "My name is... #{animal.name}!"
end

dog = Dog.new("Pochi")

cry(dog)
