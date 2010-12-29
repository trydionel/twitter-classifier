#!/usr/bin/env ruby -KU

require 'rubygems'
require 'classifier'
require 'json'
require 'twitter/json_stream'

require 'term/ansicolor'
include Term::ANSIColor

@classifier = Classifier::Bayes.new 'retweeted', 'not retweeted'

def evaluate(tweet, options = {})
  return unless tweet['retweet_count'] && tweet['text']
  return unless tweet['user'] && tweet['user']['lang'] == 'en'

  options  = { :training  => true }.merge(options)
  category = tweet['retweet_count'].to_i > 0 ? 'retweeted' : 'not retweeted'

  if options[:training]
    @classifier.train category, tweet['text']

    return :training
  else
    actual = @classifier.classify(tweet['text']).downcase
    if category == actual
      puts "'#{tweet['text'].white.bold}' was correctly classified as #{actual.green}"
    else
      puts "'#{tweet['text'].white.bold}' was incorrectly classified as #{actual.red}"
    end 

    return :testing, category == actual
  end
end

counts = Hash.new { |hash, key| hash[key] = 0 }
stats = []
accuracy = "-"

EventMachine.run do
  stream = Twitter::JSONStream.connect(
    :path => '/1/statuses/sample.json',
    :auth => "#{ENV['TWITTER_USER']}:#{ENV['TWITTER_PASSWD']}"
  )

  stream.each_item do |item|
    tweet = JSON.parse(item) rescue next
    evaluated, result = evaluate(tweet, :training => counts[:all] < 100 || rand < 0.9)

    if evaluated
      counts[evaluated] += 1
      counts[:all] += 1

      if evaluated == :testing
        stats << result
        stats.shift if stats.length > 100
        accuracy = stats.count { |s| s } / stats.length.to_f * 100
      end

      print " #{counts[:all].to_s.rjust(5)} Tweets Evaluated (#{accuracy.round(2)}% accurate over last #{stats.length})\r"
    end
  end

  stream.on_error do |error|
    STDERR.puts error.inspect
  end
end

