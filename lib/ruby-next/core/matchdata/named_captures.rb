# frozen_string_literal: true

if MatchData.instance_methods(false).include?(:named_captures)
  RubyNext::Core.patch MatchData, method: :named_captures, version: "3.3", supported: "a".match(/a/).method(:named_captures).arity != 0, core_ext: :prepend do
    <<-'RUBY'
  def named_captures(symbolize_names: false)
    return super() unless symbolize_names

    super().transform_keys!(&:to_sym)
  end
    RUBY
  end
end
