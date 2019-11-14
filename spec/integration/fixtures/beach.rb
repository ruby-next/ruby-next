# source: https://learnyousomeerlang.com/syntax-in-functions#in-case-of

def beach(*temperature)
  case temperature
  in :celcius | :c, (20..45)
    :favorable
  in :kelvin | :k, (293..318)
    :scientifically_favorable
  in :kelvin | :k, (5_778...)
    :burning_on_the_sun
  in :fahrenheit | :f, (68..113)
    :favorable_in_us
  else
    :avoid_beach
  end
end

if ARGV.size == 2
  p beach(ARGV[0].to_sym, ARGV[1].to_i)
end
