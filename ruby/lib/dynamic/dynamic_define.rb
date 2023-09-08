# class Sample
#   # @dynamic dynamic_method
#   define_method :dynamic_method do
#     "dynamic_method"
#   end
# end

# def put_dynamic_method(sample)
#   puts sample.dynamic_method
# end

# put_dynamic_method(Sample.new)

class Sample
  # @dynamic dynamic_method
  define_method :dynamic_method do
    "dynamic_method"
  end
end

puts Sample.new.dynamic_method
