require 'ripper'
require 'pp'

code = <<STR
a = 100
b = 200
p a + b
STR
puts code
pp Ripper.sexp(code)
