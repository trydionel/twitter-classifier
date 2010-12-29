module Processors
  module Noop
    extend self

    def process(text)
      text.split
    end

  end
end
