# frozen_string_literal: true

require "benchmark/ips"

GC.disable

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

def beach_next(*temperature)
  __matchee__ = temperature
  if (((__matchee_arr__ ||= __matchee__.deconstruct) && (((:celcius === __matchee_arr__[0]) || (:c === __matchee_arr__[0])) && ((n = __matchee_arr__[1]) || true))) && ((n >= 20) && (n <= 45)))
    :favorable
  else
    if (((__matchee_arr__ ||= __matchee__.deconstruct) && (((:kelvin === __matchee_arr__[0]) || (:k === __matchee_arr__[0])) && ((n = __matchee_arr__[1]) || true))) && ((n >= 293) && (n <= 318)))
      :scientifically_favorable
    else
      if (((__matchee_arr__ ||= __matchee__.deconstruct) && (((:fahrenheit === __matchee_arr__[0]) || (:f === __matchee_arr__[0])) && ((n = __matchee_arr__[1]) || true))) && ((n >= 68) && (n <= 113)))
        :favorable_in_us
      else
        :avoid_beach
      end
    end
  end
end


Benchmark.ips do |x|
  x.config(time: 5, warmup: 1)
 
  x.report("base") do
    beach :f, 112
  end
 
  x.report("next") do
    beach_next :f, 112
  end
 
  x.compare!
end