require 'ripper'
require 'pp'

code = <<STR
puts 2+2
STR

puts RubyVM::InstructionSequence.compile(code).disasm
