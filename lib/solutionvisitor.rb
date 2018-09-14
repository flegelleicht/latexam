require_relative './examvisitor'

class SolutionVisitor < ExamVisitor
  def initialize
    super()
    @templAnswerSolutionTrue  = File.read(File.join(File.dirname(__FILE__), 'templates/answer.solution.true.tex'))
    @templAnswerSolutionFalse = File.read(File.join(File.dirname(__FILE__), 'templates/answer.solution.false.tex'))
  end

  def visitAnswer(answer)
    if overSelectOnly?(answer.question.topic)
      return
    end

    if @numAnswers >= @maxAnswersPerQuestion then
      # puts "Max number of answers reached."
      return
    end

    if answer.truth
      if (@maxAnswersPerQuestion - @numAnswers) <= (@minWrongAnswersPerQuestion - @numWrongAnswers) then return end
    end

    unless answer.truth
      if (@maxAnswersPerQuestion - @numAnswers) <= (@minRightAnswersPerQuestion - @numRightAnswers) then return end
    end


    if answer.title =~ /(\.png|\.jpg)$/
      answer.title = @templAnswerImageTitle.gsub('#{answer.title}', "#{answer.title}")
    end

    if answer.truth == true
      @output += @templAnswerSolutionTrue
                  .gsub('#{answer.question.topic.id}', "#{answer.question.topic.id}")
                  .gsub('#{answer.question.id}', "#{answer.question.id}")
                  .gsub('#{answer.id}', "#{answer.id}")
                  .gsub('#{answer.title}', "#{answer.title}") 
    else
      @output += @templAnswerSolutionFalse
                  .gsub('#{answer.question.topic.id}', "#{answer.question.topic.id}")
                  .gsub('#{answer.question.id}', "#{answer.question.id}")
                  .gsub('#{answer.id}', "#{answer.id}")
                  .gsub('#{answer.title}', "#{answer.title}") 
    end
    
    # FIXME: Behavior should not depend on counting.
    #        We'll have to fix it in Latexam::Exam#make
    #        where the exam key always contains all keys for
    #        all entries, even if the visitor did not include them
    @numAnswers += 1
    @numRightAnswers += 1 if answer.truth
    @numWrongAnswers += 1 unless answer.truth
  end
end
