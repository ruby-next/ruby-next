# frozen_string_literal: true

# Extend `Language.transform` to inject `using RubyNext` to every file
RubyNext::Language.singleton_class.prepend(Module.new do
  def transform(contents, **hargs)
    # We cannot activate refinements in eval
    RubyNext::Core.inject!(contents) unless hargs[:eval]
    super(contents, **hargs)
  end
end)
