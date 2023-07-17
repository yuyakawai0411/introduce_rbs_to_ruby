require 'ripper'
require 'pp'

code = <<STR
puts 2+2
STR
puts code
pp Ripper.sexp(code)
