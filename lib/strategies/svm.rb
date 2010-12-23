require 'svm'

module Strategies
  class SVM

    attr_accessor :processor
    attr_accessor :categorizer

    attr_accessor :dictionary
    attr_accessor :categories
    attr_accessor :vectors
    attr_accessor :param
    attr_accessor :problem
    attr_accessor :model

    def initialize(processor, categorizer)
      @processor   = processor
      @categorizer = categorizer
    end

    def build(tweets)
      @dictionary = build_dictionary(tweets)
    end

    def train(training)
      @categories = training.map { |tweet| categorize(tweet) }
      @vectors    = training.map { |tweet| vectorize(tweet, :with => dictionary) }
      @param      = Parameter.new(:kernel_type => LINEAR, :C => 10)
      @problem    = Problem.new(categories, vectors)
      @model      = Model.new(problem, param)

      model.save('tweets.model')
    end

    def classify(tweet)
      vector        = vectorize(tweet, :with => dictionary)
      actual, probs = model.predict_probability(vector)

      actual
    end

    def categorize(tweet)
      categorizer.categorize(tweet)
    end

    def to_text(category)
      categorizer.to_text(category)
    end

  private

    def build_dictionary(tweets)
      tweets.map do |tweet|
        processor.process(tweet['text'])
      end.flatten.uniq
    end

    def vectorize(tweet, options = {})
      dictionary = options[:with]
      text = tweet.is_a?(String) ? tweet : tweet['text']
      data = processor.process(text)

      if options[:dense]
        # "dense" representation
        #
        dictionary.map { |word| data.include?(word) ? 1 : 0 } 
      else
        # "sparse" representation
        #
        dictionary.to_enum.with_index.each_with_object({}) do |(word, index), hash|
          hash[index] = 1 if data.include?(word)
        end
      end
    end
    
  end
end
