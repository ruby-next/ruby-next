# frozen_string_literal: true

module Test
  def delegate(...)
    object.call(...)
  end

  def super_delegate(...)
    super(...)
  end

  def anoblock(&)
    delegate(&)
  end

  def super_anoblock(&)
    super(&)
  end
end
