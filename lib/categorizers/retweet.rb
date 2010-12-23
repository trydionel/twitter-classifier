module Categorizers
  module Retweet
    extend self

    def categories
      ['Not Retweeted', 'Retweeted']
    end

    def categorize(tweet, value = true)
      result = tweet['retweet_count'] > 0 ? 'Retweeted' : 'Not Retweeted'
      value ? to_value(result) : result
    rescue
      STDERR.puts "Failed to collect retweet count:\t#{tweet.inspect}"
      value ? 0 : 'Not Retweeted'
    end

    def to_text(value)
      categories[value]
    end

    def to_value(category)
      categories.index(category)
    end

  end
end
