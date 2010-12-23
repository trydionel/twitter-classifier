require 'classifier'

module Strategies
  class Bayes

    attr_accessor :processor
    attr_accessor :categorizer
    attr_accessor :classifier

    def initialize(processor, categorizer)
      @processor   = processor
      @categorizer = categorizer
    end

    def build(tweets)
      @classifier = Classifier::Bayes.new *categorizer.categories
    end

    def train(training)
      training.each do |tweet|
        category = categorize(tweet)
        classifier.train category, tweet['text']
      end
    end

    def classify(tweet)
      classifier.classify processor.process(tweet['text']).join(' ')
    end

    def categorize(tweet)
      categorizer.categorize(tweet, false)
    end

    def to_text(value)
      value
    end

  end
end


