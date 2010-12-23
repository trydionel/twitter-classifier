#!/usr/bin/env ruby -KU

require 'rubygems'

$:.unshift('lib')
require 'twitter/classifier'
require 'processors/stemmer'
require 'categorizers/happy'
require 'strategies/svm'

Twitter::Classifier.run(
  Strategies::SVM.new(Processors::Stemmer, Categorizers::Happy),
  :user  => (ENV['TWITTER_USER'] || 'trydionel').dup,
  :count => ENV['MORE_TWEETS'] ? 1000 : 200)

exit 0
