#! /usr/bin/env ruby

if ARGV.length < 2
  puts "Usage: #{__FILE__} <exam catalog file> <latex output file>"
  exit -1
end

require_relative "../lib/latexam"
require_relative "../lib/examvisitor.rb"

load(ARGV[0])
visitor = ExamVisitor.new
make(visitor)
visitor.write(ARGV[1])
