require 'stemmer'

module Processors
  module Stemmer
    extend self

    # Returns an array of stemmed words with length > 2.
    #
    def stem(text)
      text.split.map do |word|
        cleaned_word = word.gsub(/\W+/, '').gsub(/(?<=http).+/, '')
        stemmed_word = ::Stemmer.stem_word(cleaned_word).downcase

        stemmed_word if stemmed_word.length > 2
      end.compact
    end
    alias_method :process, :stem

  end
end
