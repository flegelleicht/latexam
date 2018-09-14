if ARGV.length < 3
  puts "Usage: #{__FILE__} <exam catalog file> <latex output file> <exam key>"
  exit -1
end

require_relative "../lib/latexam"
require_relative "../lib/solutionvisitor.rb"

load(ARGV[0])
visitor = SolutionVisitor.new
makeSpecific(ARGV[2], visitor)
visitor.write(ARGV[1])
