#!/usr/bin/env ruby -KU

require 'rubygems'

require 'term/ansicolor'
include Term::ANSIColor

require 'stemmer'
require 'classifier'

require File.join(File.dirname(__FILE__), 'classifier')

class BayesClassifier

  attr_accessor :classifier

  def build(tweets)
    @classifier = Classifier::Bayes.new 'Retweeted', 'Not Retweeted'
  end

  def train(training)
    training.each do |tweet|
      category = categorize(tweet)
      classifier.train category, tweet.text
    end
  end

  def classify(tweet)
    classifier.classify stemmed_tweet(tweet.text).join(' ')
  end

  def categorize(tweet)
    tweet.retweet_count > 0 ? 'Retweeted' : 'Not Retweeted'
  end

  def to_text(category)
    category
  end

private

  def stemmed_tweet(tweet)
    tweet.split.map do |word|
      cleaned_word = word.gsub(/\W+/, '').gsub(/(?<=http).+/, '')
      stemmed_word = Stemmer.stem_word(cleaned_word).downcase

      stemmed_word if stemmed_word.length > 2
    end.compact
  end

end

Twitter::Classifier.run BayesClassifier.new,
  :user  => (ENV['TWITTER_USER'] || 'trydionel').dup,
  :count => ENV['MORE_TWEETS'] ? 1000 : 200

exit 0
