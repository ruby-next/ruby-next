class KwargSpecs
  def call(*args, **kwargs)
    [args, kwargs]
  end
end
