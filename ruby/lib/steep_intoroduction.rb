currencies = { US: "$", JP: "¥", UK: "£" }
country = %w(US JP UK).sample() or raise

puts "Hello! The price is #{currencies[country.to_sym]}100"
