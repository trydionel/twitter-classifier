#!/usr/bin/env ruby -KU

require 'rubygems'

$:.unshift('lib')
require 'processors/stemmer'
require 'categorizers/retweet'
require 'strategies/bayes'
require 'twitter/classifier'

Twitter::Classifier.run(
  Strategies::Bayes.new(Processors::Stemmer, Categorizers::Retweet),
  :user  => (ENV['TWITTER_USER'] || 'trydionel').dup,
  :count => ENV['MORE_TWEETS'] ? 1000 : 200)

exit 0
