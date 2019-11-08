def beach(*temperature)
  case temperature
  in :celcius | :c, n if (n >= 20) and (n <= 45)
    :favorable
  in :kelvin | :k, n if (n >= 293) and (n <= 318)
    :scientifically_favorable
  in :fahrenheit | :f, n if (n >= 68) and (n <= 113)
    :favorable_in_us
  else
    :avoid_beach
  end
end
