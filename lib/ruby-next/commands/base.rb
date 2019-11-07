# frozen_string_literal: true

require "optparse"

module RubyNext
  module Commands
    class Base
      class << self
        def run(args)
          new(args).run
        end
      end

      def initialize(args)
        parse! args
      end

      def parse!(*)
        raise NotImplementedError
      end

      def run
        raise NotImplementedError
      end
    end
  end
end
