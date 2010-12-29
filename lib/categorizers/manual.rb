require 'term/ansicolor'
include Term::ANSIColor

module Categorizers
  module Manual
    extend self

    def categories
      return @categories if @categories

      @categories = []

      puts "Enter categories, one per line (blank line to finish):"
      '> '.display
      input = gets.chomp
      while input != ''
        @categories << input
        '> '.display
        input = gets.chomp
      end

      @categories
    end

    def categorize(tweet, value = true)
      if cache[tweet['id']]
        category_id = cache[tweet['id']].to_i
      else
        helper_text = categories.map.with_index { |c, i| [c, i].join(' = ') }.join(', ')
        puts "Select category for #{tweet['text'].bold}. #{helper_text}"
        '> '.display
        category_id = gets.chomp.to_i
        cache[tweet['id']] = category_id
      end

      value ? category_id : to_text(category_id)
    end

    def to_text(value)
      categories[value]
    end

    def to_value(category)
      categories.index(category)
    end

  private

    def cache
      return @cache if @cache

      @cache = Redis.new
    rescue
      @cache = Hash.new
    end

  end
end
