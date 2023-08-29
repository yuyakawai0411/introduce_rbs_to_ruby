module Put
  def put_alphabet
    puts "alphabet"
  end
end

class Alphabet
end

class A < Alphabet
  include Put
end

class Sample
  include Put
end
