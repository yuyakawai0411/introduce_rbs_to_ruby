sample_1 = {name: 'Pochi'}
sample_2 = {age: 10}
sample_3 = {name: 'Pochi', age: 10 }

def say_name(hash)
  puts "#{hash}です!!"
end

def say_age(hash)
  puts "#{hash}歳です!!"
end

def say_name_and_age(hash)
  puts "#{hash}です!! #{hash}歳です!!"
end

say_name(sample_1)
say_age(sample_2)
say_name_and_age(sample_3)
