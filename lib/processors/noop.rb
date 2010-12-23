module Processors
  module Noop
    extend self

    def process(text)
      text
    end

  end
end
