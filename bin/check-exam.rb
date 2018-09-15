# LINK https://www.pdflabs.com/docs/pdftk-man-page/#dest-op-dump-data-fields-utf8
# LINK https://github.com/andrewgarner/docker-pdftk
# LINK https://tex.stackexchange.com/questions/136599/checkbox-from-hyperref-tick-by-default
# LINK https://www.tug.org/applications/hyperref/manual.html#x1-220006.2
def extractFields(filename) #returns map
  lines = File.read(filename)
  split = lines.split /---\r?\n/
  splits = []
  split.each do |e|
    tmp = e.split /\r?\n/
    splits << tmp
  end
  map = {}
  splits.each do |field|
    n = nil
    v = nil
    field.each do |attr|
      # if attr =~/FieldName: (.*)/
      if attr =~/FieldName: (t\dq\d\d?)/
        n = $1
      end
      if attr =~/FieldValue: (.*)/
        if $1 =~ /Ja|Yes/
          v = true
        else 
          v = false
        end
      end
    end
    if n != nil
      if v == nil then v = false end # sometimes, the FieldValue might be missing; we then assume it's false
      #puts "map[#{n}] => #{v}"
      map[n] = map[n] || []
      map[n] << v
    end
  end
  return map
end

def compare(t,o) # returns {correct: , incorrect: , ratio: }
  correct = 0.0
  incorrect = 0.0
  o.keys.each do |ans|
    if t[ans] == o[ans]
      correct = correct + 1
      puts "1"
    else
      incorrect = incorrect + 1
      puts "0"
    end
  end
  return { correct: correct, incorrect: incorrect, ratio: (correct/(correct+incorrect))}
end

if ARGV.length < 2
	puts "Usage: <script> <path-to-exam.pdf> <path-to-solution.pdf>"
else
	exam = ARGV[0]
	solution = ARGV[1]

	system("pdftk #{exam} dump_data_fields_utf8 > #{exam}.fields.txt")
	system("pdftk #{solution} dump_data_fields_utf8 > #{solution}.fields.txt")


	theirs = extractFields("#{exam}.fields.txt")
	ours = extractFields("#{solution}.fields.txt")
	result = compare(theirs, ours)

	puts "correct:\t#{result[:correct]}"
	puts "incorrect:\t#{result[:incorrect]}"
	puts "ratio:\t#{result[:ratio]}"
end

