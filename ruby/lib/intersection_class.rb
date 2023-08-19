class Sample1
  # @dynamic a_attr, b_attr
  attr_reader :a_attr, :b_attr

  def initialize(a_attr, b_attr)
    @a_attr = a_attr
    @b_attr = b_attr
  end
end

class Sample2
  # @dynamic b_attr, c_attr
  attr_reader :b_attr, :c_attr

  def initialize(b_attr, c_attr)
    @b_attr = b_attr
    @c_attr = c_attr
  end
end

class Sample3
  # @dynamic a_attr, b_attr, c_attr
  attr_reader :a_attr, :b_attr, :c_attr

  def initialize(a_attr, b_attr, c_attr)
    @a_attr = a_attr
    @b_attr = b_attr
    @c_attr = c_attr
  end
end

def put_a(object)
  puts object.a_attr
end

def put_c(object)
  puts object.c_attr
end

# def put_a_and_c(object)
#   puts object.a_attr
#   puts object.c_attr
# end

sample_1 = Sample1.new(1, 2)
sample_2 = Sample2.new(2, 3)
# sample_3 = Sample3.new(1, 2, 3)

put_a(sample_1)
put_c(sample_2)
# put_a_and_c(sample_3)
