#!/usr/bin/env ruby -KU

require 'rubygems'

$:.unshift('lib')
require 'processors/noop'
require 'categorizers/manual'
require 'strategies/bayes'
require 'twitter/classifier'

Twitter::Classifier.run(
  Strategies::Bayes.new(Processors::Noop, Categorizers::Manual),
  :user  => (ENV['TWITTER_USER'] || 'trydionel').dup,
  :count => 20,
  #:count => ENV['MORE_TWEETS'] ? 1000 : 200)
)

exit 0

