# frozen_string_literal: true

require "json"

def main(val)
  "status: " + JSON.:parse.call(val)["status"].to_s
end

# p main('{}') #=> "status: nil"
# p main('{"status":"ok"}') #=> "status: ok"
