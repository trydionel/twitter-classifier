require 'twitter'

class Array
  def split(n)
    return self[0...n], self[n..-1]
  end
end

module Twitter
  class Classifier

    def self.run(strategy, options)
      classifier = self.new(strategy, options)

      classifier.build!
      classifier.train!
      classifier.verify! if options[:verify]
      classifier.predict!
      classifier.console! if options[:console]
    end

    attr_accessor :strategy
    attr_accessor :options
    attr_accessor :tweets

    attr_accessor :training
    attr_accessor :testing

    def initialize(strategy, options = {})
      @strategy = strategy
      @options  = default_options.merge(options)
      @tweets   = []

      collect!
    end

    def default_options
      {
        :user      => 'trydionel',
        :count     => 200,
        :test_size => 10,
        :verify    => true,
        :verbose   => true,
        :console   => false
      }
    end

    def collect!
      puts "Collecting tweets..." if verbose?
      while tweets.size < options[:count]
        begin
          tweet_options = { :count => 200 }
          tweet_options[:max_id] = tweets.last.id unless tweets.empty?

          tweets.concat Twitter.user_timeline(options[:user], tweet_options)
        rescue
          # no op
        end
      end
    end

    def build!
      puts "Processing text..." if verbose?
      strategy.build(tweets)

      @testing, @training = tweets.split(options[:test_size])
    end

    def train!
      puts "Training classifier..." if verbose?
      strategy.train(training)
    end

    def verify!
      puts "Verifying training set..." if verbose?
      
      errors = 0
      training.each do |tweet|
        expected = strategy.categorize(tweet)
        actual   = strategy.classify(tweet)
        errors += 1 unless actual == expected
      end
      puts "Found #{errors} errors in the training set!" if errors > 0
    end

    def predict!
      puts "Executing tests..." if verbose?

      testing.each do |tweet|
        expected = strategy.categorize(tweet)
        actual   = strategy.classify(tweet)
        if expected == actual
          puts "'#{tweet.text.white.bold}' was correctly classified as #{strategy.to_text(actual).green}"
        else
          puts "'#{tweet.text.white.bold}' was incorrectly classified as #{strategy.to_text(actual).red}"
        end
      end
    end

    def console!
      '> '.display
      while input = gets
        puts strategy.to_text(strategy.classify(input.chomp))
        '> '.display
      end
    end

  private

    def verbose?
      !!options[:verbose]
    end

  end
end
