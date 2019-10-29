# source: https://github.com/ruby/spec/blob/master/core/proc/shared/compose.rb

describe :proc_compose, shared: true do
  # Skip JRuby 'cause it doesn't support refinements in `send`
  # See https://github.com/jruby/jruby/issues/5945
  next if RUBY_PLATFORM =~ /java/i
  # Ruby 2.6 had a slightly different behaviour https://bugs.ruby-lang.org/issues/15428
  next if RUBY_VERSION =~ /\b2\.6/

  ruby_version_is "2.7" do # https://bugs.ruby-lang.org/issues/15428
    it "raises TypeError if passed not callable object" do
      lhs = @object.call
      not_callable = Object.new

      -> {
        lhs.send(@method, not_callable)
      }.should raise_error(TypeError, "callable object is expected")

    end

    it "does not try to coerce argument with #to_proc" do
      lhs = @object.call

      succ = Object.new
      def succ.to_proc(s); s.succ; end

      -> {
        lhs.send(@method, succ)
      }.should raise_error(TypeError, "callable object is expected")
    end
  end
end
