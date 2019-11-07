class B
  def self.match(val)
    case val
    in 1 | 2
      true
    else
      false
    end
  end
end
