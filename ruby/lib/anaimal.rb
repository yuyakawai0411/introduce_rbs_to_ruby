class Animal
  attr_reader :name

  def initialize(name)
    @name = name
  end
end

class Cat < Animal
end

class Dog < Animal
end

def cry(animal)
  puts "My name is... #{animal.name}!"
end

dog = Dog.new("Pochi")

cry(dog)
