require 'ripper'
require 'pp'

code = <<STR
10.times do |i|
  print i, " "
end
STR
puts code
pp Ripper.sexp(code)
