class Alphabet
end

class A < Alphabet
end

def put_alphabet(alphabet)
  puts "#{alphabet.class}"
end

alphabet = A.new
put_alphabet(alphabet)
