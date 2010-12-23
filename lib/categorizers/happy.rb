module Categorizers
  module Happy
    extend self

    TOKENS    = %w[like love joy happy fun best win lol ftw dream]
    THRESHOLD = 2.0

    def categories
      ['Sad', 'Happy']
    end

    def categorize(tweet, value = true)
      text  = tweet['text'].downcase
      count = TOKENS.inject(0) do |cnt, token|
        cnt += 1 if text.include?(token)
        cnt
      end

      result = [count/THRESHOLD, 1.0].min.round
      value ? result : to_text(result)
    end

    def to_text(value)
      categories[value]
    end

    def to_value(text)
      categories.index(text)
    end

  end
end
