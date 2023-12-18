# frozen_string_literal: true

module RubyNext
  module Language
    module Rewriters
      class AnonymousRestArgs < Base
        NAME = "anonymous-rest-args"
        SYNTAX_PROBE = "obj = Object.new; def obj.foo(*) bar(*); end"
        MIN_SUPPORTED_VERSION = Gem::Version.new("3.2.0")

        REST = :__rest__
        KWREST = :__kwrest__

        def on_args(node)
          rest = node.children.find { |child| child.is_a?(::Parser::AST::Node) && child.type == :restarg && child.children.first.nil? }
          kwrest = node.children.find { |child| child.is_a?(::Parser::AST::Node) && child.type == :kwrestarg && child.children.first.nil? }

          return super unless rest || kwrest

          context.track! self

          replace(rest.loc.expression, "*#{REST}") if rest
          replace(kwrest.loc.expression, "**#{KWREST}") if kwrest

          new_args = node.children.map do |child|
            if child == rest
              s(:restarg, REST)
            elsif child == kwrest
              s(:kwrestarg, KWREST)
            else
              child
            end
          end

          node.updated(:args, new_args)
        end

        def on_send(node)
          return super unless forwarded_args?(node)

          process_send_args(node)
        end

        def on_super(node)
          return super unless forwarded_args?(node)

          process_send_args(node)
        end

        private

        def forwarded_args?(node)
          node.children.each do |child|
            next unless child.is_a?(::Parser::AST::Node)

            if child.type == :forwarded_restarg
              return true
            elsif child.type == :kwargs
              child.children.each do |kwarg|
                next unless kwarg.is_a?(::Parser::AST::Node)

                return true if kwarg.type == :forwarded_kwrestarg
              end
            end
          end

          false
        end

        def process_send_args(node)
          process(
            node.updated(
              nil,
              node.children.map do |child|
                next child unless child.is_a?(::Parser::AST::Node)

                if child.type == :forwarded_restarg
                  replace(child.loc.expression, "*#{REST}")
                  s(:ksplat, s(:lvar, REST))
                elsif child.type == :kwargs
                  child.updated(
                    nil,
                    child.children.map do |kwarg|
                      next kwarg unless kwarg.is_a?(::Parser::AST::Node)

                      if kwarg.type == :forwarded_kwrestarg
                        replace(kwarg.loc.expression, "**#{KWREST}")
                        s(:kwsplat, s(:lvar, KWREST))
                      else
                        kwarg
                      end
                    end
                  )
                else
                  child
                end
              end
            )
          )
        end
      end
    end
  end
end
