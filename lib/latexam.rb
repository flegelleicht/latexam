module Latexam
  class Exam
    def initialize
      @topics = []
    end
    attr_accessor :topics
  end
  
  class Topic
    @@num = 0
    def initialize(title)
      @title = title
      @questions = []
      @amount = -1
      @id = @@num
      @@num += 1

    end
    attr_accessor :title, :questions, :id, :amount
  end
  
  class Question
    @@num = 0
    def initialize(title)
      @title = title
      @answers = []
      @score = 0
      @pos = 0
      @id = @@num
      @@num += 1
    end
    attr_accessor :title, :answers, :score, :pos, :image, :freeform, :id, :topic
  end
  
  class Answer
    @@num = 0
    def initialize(truth, title)
      @truth = truth
      @title = title
      @pos = 0
      @id = @@num
      @@num += 1
    end
    attr_accessor :truth, :title, :pos, :id, :question
  end
  
  module Dsl    
    def topic(title, &block)
      @exam = @exam || Exam.new
      topic = Topic.new title
      @exam.topics << topic
      block.call if block_given?
    end
    
    def selectOnly(nr)
      @exam.topics.last.amount = nr
    end
    
    def question(title, &block)
      question = Question.new title
      question.pos = @exam.topics.last.questions.size
      question.topic = @exam.topics.last
      @exam.topics.last.questions << question
      block.call if block_given?
    end
    
    def questionimage(src, &block)
      @exam.topics.last.questions.last.image = src
      block.call if block_given?
    end
    
    def freeform(text)
      @exam.topics.last.questions.last.freeform = text
    end
    
    def right(title)
      answer = Answer.new(true, title)
      answer.pos = @exam.topics.last.questions.last.answers.size
      answer.question = @exam.topics.last.questions.last
      @exam.topics.last.questions.last.answers << answer
    end
    
    def wrong(title)
      answer = Answer.new(false, title)
      answer.pos = @exam.topics.last.questions.last.answers.size
      answer.question = @exam.topics.last.questions.last
      @exam.topics.last.questions.last.answers << answer
    end
    
    def score(amount)
      @exam.topics.last.questions.last.score = amount
    end
    
    def method_missing(meth,*args,&block)
    end
    
    def make(visitor)
      key = ""
      @exam.topics.each do |topic|
        key += "t"
        visitor.visitTopic topic
        
        topic.questions.shuffle.each do |question|
          key += "q#{question.pos}"
          visitor.visitQuestion question
          
          question.answers.shuffle.each do |answer|
            key += "a#{answer.pos}"
            visitor.visitAnswer answer
          end
          
          visitor.endQuestion question
        end
      end
      puts key
      visitor.visitExamKey key
    end
    
    def makeSpecific(key, visitor, &block)
      topics = key.split("t")
      topics.shift # remove empty element at front
      topics.each_with_index do |topic, tidx|
        t = @exam.topics.at(tidx)
        puts "#{t.title}"
        visitor.visitTopic t
        
        questions = topic.split("q")
        questions.shift
        questions.each do |question|
          # puts ">> q #{question}"
          answers = question.split("a")
          qidx = answers.shift.to_i
          q = t.questions.at(qidx)
          puts "  #{q.title}"
          visitor.visitQuestion q
          
          answers.each do |answer|
            # puts ">>>> a #{answer}"
            aidx = answer.to_i
            a = q.answers.at(aidx)
            puts "    #{a.title}"
            visitor.visitAnswer a
          end
          
          visitor.endQuestion q
        end
      end
    end
    
    alias_method :thema, :topic
    alias_method :frage, :question
    alias_method :fragebild, :questionimage
    alias_method :richtig, :right
    alias_method :falsch, :wrong
    alias_method :punkte, :score
    alias_method :freitext, :freeform
    alias_method :nimmNur, :selectOnly
  end
end

extend Latexam::Dsl
