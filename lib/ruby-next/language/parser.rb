# frozen_string_literal: true

require "ruby-next/utils"
require_relative "ruby27"

RubyNext::Language::Parser = Parser::Ruby27

# Prevent from loading built-in parsers
$LOADED_FEATURES << RubyNext::Utils.resolve_feature_path("parser/current")
require "parser/current"

RubyNext::Utils.resolve_feature_path("parser/ruby27").then do |path|
  if path
    $LOADED_FEATURES << path
    require "parser/ruby27"
  end
end

# See https://github.com/whitequark/parser/#usage
Parser::Builders::Default.emit_lambda = true
Parser::Builders::Default.emit_procarg0 = true
Parser::Builders::Default.emit_encoding = true
Parser::Builders::Default.emit_index = true

# Patch builder to recognize new nodes.
# Parser doesn't release as fast we want :( So, we had to hack it a bit.
#
# Sources:
#  - https://github.com/whitequark/parser/pull/574/files
#
module Parser
  class Builders::Default
    #
    # PATTERN MATCHING
    #
    def case_match(case_t, expr, in_bodies, else_t, else_body, end_t)
      n(:case_match, [expr, *(in_bodies << else_body)],
        condition_map(case_t, expr, nil, nil, else_t, else_body, end_t))
    end

    def in_pattern(in_t, pattern, guard, then_t, body)
      children = [pattern, guard, body]
      n(:in_pattern, children,
        keyword_map(in_t, then_t, children.compact, nil))
    end

    def if_guard(if_t, if_body)
      n(:if_guard, [if_body], guard_map(if_t, if_body))
    end

    def unless_guard(unless_t, unless_body)
      n(:unless_guard, [unless_body], guard_map(unless_t, unless_body))
    end

    def match_var(name_t)
      name = value(name_t).to_sym
      @parser.static_env.declare(name)

      n(:match_var, [name],
        variable_map(name_t))
    end

    def match_hash_var(name_t)
      name = value(name_t).to_sym
      @parser.static_env.declare(name)

      expr_l = loc(name_t)
      name_l = expr_l.adjust(end_pos: -1)

      n(:match_var, [name],
        Source::Map::Variable.new(name_l, expr_l))
    end

    def match_hash_var_from_str(begin_t, strings, end_t)
      if strings.length > 1
        diagnostic :error, :pm_interp_in_var_name, nil, loc(begin_t).join(loc(end_t))
      end

      string = strings[0]

      case string.type
      when :str
        # MRI supports plain strings in hash pattern matching
        name, = *string
        name_l = string.loc.expression
        check_lvar_name(name, name_l)

        if (begin_l = string.loc.begin)
          # exclude beginning of the string from the location of the variable
          name_l = name_l.adjust(begin_pos: begin_l.length)
        end

        if (end_l = string.loc.end)
          # exclude end of the string from the location of the variable
          name_l = name_l.adjust(end_pos: -end_l.length)
        end

        expr_l = loc(begin_t).join(string.loc.expression).join(loc(end_t))
        n(:match_var, [name.to_sym],
          Source::Map::Variable.new(name_l, expr_l))
      when :begin
        match_hash_var_from_str(begin_t, string.children, end_t)
      end
    end

    def match_rest(star_t, name_t = nil)
      if name_t.nil?
        n0(:match_rest,
          unary_op_map(star_t))
      else
        name = match_var(name_t)
        n(:match_rest, [name],
          unary_op_map(star_t, name))
      end
    end

    def hash_pattern(lbrace_t, kwargs, rbrace_t)
      args = check_duplicate_args(kwargs)
      n(:hash_pattern, args,
        collection_map(lbrace_t, args, rbrace_t))
    end

    def array_pattern(lbrack_t, elements, rbrack_t)
      trailing_comma = false

      elements = elements.map do |element|
        if element.type == :match_with_trailing_comma
          trailing_comma = true
          element.children.first
        else
          trailing_comma = false
          element
        end
      end

      node_type = trailing_comma ? :array_pattern_with_tail : :array_pattern
      n(node_type, elements,
        collection_map(lbrack_t, elements, rbrack_t))
    end

    def match_with_trailing_comma(match)
      n(:match_with_trailing_comma, [match], nil)
    end

    def const_pattern(const, ldelim_t, pattern, rdelim_t)
      n(:const_pattern, [const, pattern],
        collection_map(ldelim_t, [pattern], rdelim_t))
    end

    def pin(pin_t, var)
      n(:pin, [var],
        send_unary_op_map(pin_t, var))
    end

    def match_alt(left, pipe_t, right)
      source_map = binary_op_map(left, pipe_t, right)

      n(:match_alt, [left, right],
        source_map)
    end

    def match_as(value, assoc_t, as)
      source_map = binary_op_map(value, assoc_t, as)

      n(:match_as, [value, as],
        source_map)
    end

    private

    def check_lvar_name(name, loc)
      if /\A[[[:lower:]]|_][[[:alnum:]]_]*\z/.match?(name)
        # OK
      else
        diagnostic :error, :lvar_name, {name: name}, loc
      end
    end

    def guard_map(keyword_t, guard_body_e)
      keyword_l = loc(keyword_t)
      guard_body_l = guard_body_e.loc.expression

      Source::Map::Keyword.new(keyword_l, nil, nil, keyword_l.join(guard_body_l))
    end
  end
end
