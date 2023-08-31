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

def put_name(animal)
  puts animal.name
end

puts Cat.new("Cat").name
puts Dog.new("Pochi").name
