class Array
  alias deconstruct to_a
end

class Beach < Place
  def self.call(*temperature)
    case temperature
    in :celcius | :c, (20..45)
      :favorable
    in :kelvin | :k, (293..318)
      :scientifically_favorable
    in :fahrenheit | :f, (68..113)
      :favorable_in_us
    else
      :avoid_beach
    end
  end
end
