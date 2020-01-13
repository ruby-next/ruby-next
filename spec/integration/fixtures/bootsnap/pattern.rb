# frozen_string_literal: true

require "json"

def main(msg)
  case JSON.parse(msg, symbolize_names: true)
  in {command: "subscribe", channel:}
    "SUBSCRIBE: #{channel}"
  in {command: "perform", channel:, action:}
    "PERFORM: #{channel}##{action}"
  in {command:}
    "UNKNOWN: #{command}"
  end
end
