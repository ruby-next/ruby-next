# frozen_string_literal: true

RubyNext::Core.patch Module, name: "RefinementImportMethods", method: :import_methods, version: "3.1" do
  <<-'RUBY'
def import_methods(other, bind = nil)
  unless bind
    raise ArgumentError, <<-MSG
  Using the #import_methods backport requires using Ruby Next transpiler to
  automatically pass a Binding object to this method. Otherwise it's not possible
  to correctly implement its functionality.
    MSG
  end

  import = []

  other.instance_methods(false).each do |mid|
    # check for non-Ruby methods
    meth = other.instance_method(mid)
    location = meth.source_location

    if location.nil? || location.first.match?(/(<internal:|resource:\/truffleruby\/core)/)
      raise ArgumentError, "Can't import method: #{other}##{mid}"
    end

    source_file, lineno = *location

    raise ArgumentError, "Can't import dynamicly added methods: #{other}##{mid}" unless File.file?(source_file)

    lines = File.open(source_file).readlines

    buffer = []

    lines[(lineno - 1)..-1].each do |line|
      buffer << line + "\n"

      begin
        if defined?(::RubyNext::Language) && ::RubyNext::Language.runtime?
          new_source = ::RubyNext::Language.transform(buffer.join, rewriters: RubyNext::Language.current_rewriters)
          # Transformed successfully => valid method => evaluate transpiled code
          import << [new_source, source_file, lineno]
          buffer.clear
          break
        end

        # Borrowed from https://github.com/banister/method_source/blob/81d039c966ffd95d26e12eb2e205c0eb8377f49d/lib/method_source/code_helpers.rb#L66
        catch(:valid) do
          eval("BEGIN{throw :valid}\nObject.new.instance_eval { #{buffer.join} }")
        end
        break
      rescue SyntaxError
      end
    end

    import << [buffer.join, source_file, lineno] unless buffer.empty?
  end

  import.each do |(definition, file, lino)|
    Kernel.eval definition, bind, file, lino
  end

  # Copy constants (they could be accessed from methods)
  other.constants.each do |name|
    Kernel.eval "#{name} = #{other}::#{name}", bind
  end
end
  RUBY
end
