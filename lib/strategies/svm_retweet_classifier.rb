#!/usr/bin/env ruby -KU

require 'rubygems'

require 'term/ansicolor'
include Term::ANSIColor

require 'stemmer'
require 'svm'

$:.unshift('.')
require 'classifier'

class SVMClassifier

  CATEGORIES = ['Not Retweeted', 'Retweeted']

  attr_accessor :dictionary
  attr_accessor :categories
  attr_accessor :vectors
  attr_accessor :param
  attr_accessor :problem
  attr_accessor :model

  def build(tweets)
    @dictionary = build_dictionary(tweets)
  end

  def train(training)
    @categories = training.map { |tweet| categorize(tweet) }
    @vectors    = training.map { |tweet| vectorize(tweet, :with => @dictionary) }
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
    tweet.retweet_count > 0 ? 1 : 0
  rescue
    STDERR.puts "Failed to collect retweet count:\t#{tweet.inspect}"
    0
  end

  def to_text(category)
    CATEGORIES[category]
  end

private

  def stemmed_tweet(tweet)
    tweet.split.map do |word|
      cleaned_word = word.gsub(/\W+/, '').gsub(/(?<=http).+/, '')
      stemmed_word = Stemmer.stem_word(cleaned_word).downcase

      stemmed_word if stemmed_word.length > 2
    end.compact
  end

  def build_dictionary(tweets)
    tweets.map do |tweet|
      stemmed_tweet(tweet.text)
    end.flatten.uniq
  end

  def vectorize(tweet, options = {})
    dictionary = options[:with]
    text = tweet.is_a?(String) ? tweet : tweet.text
    data = stemmed_tweet(text)

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

Twitter::Classifier.run SVMClassifier.new,
  :user  => (ENV['TWITTER_USER'] || 'trydionel').dup,
  :count => ENV['MORE_TWEETS'] ? 1000 : 200

exit 0
