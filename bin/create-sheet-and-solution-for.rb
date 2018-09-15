#! /usr/bin/env ruby
require 'fileutils'

texfolder = "data/"
results = "exams/"

name = ARGV[0]
catalog = ARGV[1] || "#{texfolder}catalog/example.txt"
prefix = ARGV[2] || "exam"

# Generate
basename = "#{prefix}#{name}"
sheet = "#{basename}.tex"
key = `ruby bin/create-exam.rb #{catalog} #{texfolder}#{sheet}`
puts "#{key}"
solution = "#{basename}_solution.tex"
`ruby bin/create-specific-exam.rb #{catalog} #{texfolder}#{solution} #{key}`

# Compile
Dir.chdir(texfolder)
`latexmk -xelatex #{sheet}`
`latexmk -c #{sheet}`
`latexmk -xelatex #{solution}`
`latexmk -c #{solution}`

# Cleaning up
Dir.chdir("..")
FileUtils.mv(Dir.glob("#{texfolder}#{basename}*"), "#{results}")
