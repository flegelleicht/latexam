class ExamVisitor
  def initialize
    @output = ""
    @maxAnswersPerQuestion = 5
    @minRightAnswersPerQuestion = 2
    @minWrongAnswersPerQuestion = 1
    
    @templTopicTitle        = File.read(File.join(File.dirname(__FILE__), 'templates/topic.title.tex'))
    @templQuestionTitle     = File.read(File.join(File.dirname(__FILE__), 'templates/question.title.tex'))
    @templQuestionImage     = File.read(File.join(File.dirname(__FILE__), 'templates/question.image.tex'))
    @templQuestionFreeform  = File.read(File.join(File.dirname(__FILE__), 'templates/question.freeform.tex'))
    @templQuestionPostamble = File.read(File.join(File.dirname(__FILE__), 'templates/question.postamble.tex'))
    @templAnswerImageTitle  = File.read(File.join(File.dirname(__FILE__), 'templates/answer.imagetitle.tex'))
    @templAnswerText        = File.read(File.join(File.dirname(__FILE__), 'templates/answer.text.tex'))
  end

  def resetTopic
    @numQuestions = 0
  end

  def resetQuestion
    @numAnswers = 0
    @numRightAnswers = 0
    @numWrongAnswers = 0
  end

  def overSelectOnly?(topic)
    if topic.amount != -1 and topic.amount <= @numQuestions
      return true
    else
      return false
    end
  end

  def visitTopic(topic)
    resetTopic
    @output += @templTopicTitle.gsub('#{topic.title}', "#{topic.title}")
  end

  def visitQuestion(question)
    if overSelectOnly?(question.topic)
      return
    end

    resetQuestion
    
    @output += @templQuestionTitle.gsub('#{question.title}', "#{question.title}")
    
    unless question.image == nil
      @output += @templQuestionImage.gsub('#{question.image}', "#{question.image}")
    end
  end

  def endQuestion(question)
    if overSelectOnly?(question.topic)
      return
    end

    unless question.freeform == nil
      @output += @templQuestionFreeform
                    .gsub('#{question.freeform}', "#{question.freeform}")
                    .gsub('#{question.id}', "#{question.id}")
    end
    
    @output += @templQuestionPostamble
    @numQuestions += 1
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

    @output += @templAnswerText
                  .gsub('#{answer.question.topic.id}', "#{answer.question.topic.id}")
                  .gsub('#{answer.question.id}', "#{answer.question.id}")
                  .gsub('#{answer.id}', "#{answer.id}")
                  .gsub('#{answer.title}', "#{answer.title}")

    @numAnswers += 1
    @numRightAnswers += 1 if answer.truth
    @numWrongAnswers += 1 unless answer.truth
  end

  def visitExamKey(key)
    @examKey = key
  end

  def write(name)
    File.open(name, "w") do |f|
      f.write(File.read(File.join(File.dirname(__FILE__), 'templates/preamble.tex')))
      f.write @output
      f.write(File.read(File.join(File.dirname(__FILE__), 'templates/postamble.tex')).gsub('#{@examKey}', "#{@examKey}"))
    end
  end
end
