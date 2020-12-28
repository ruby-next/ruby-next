# frozen_string_literal: true

require "json"

module Txen
  VERSION = JSON.method(:parse).call(%q({"version":"0.1.0"})).fetch("version")
end
