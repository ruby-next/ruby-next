# frozen_string_literal: true

# Extend `Language.transform` to inject `using RubyNext` to every file
RubyNext::Language.singleton_class.prepend(Module.new do
  def transform(contents)
    contents.sub!(/^(\s*[^#\s].*)/, 'using RubyNext;\1')
    super(contents)
  end
end)
