# frozen_string_literal: true

module RubyNext
  module Language
    module Rewriters
      class Base < ::Parser::TreeRewriter
        def s(type, *children)
          ::Parser::AST::Node.new(type, children)
        end
      end
    end
  end
end
