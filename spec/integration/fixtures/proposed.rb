# frozen_string_literal: true

require "backports/2.5" if ENV["CORE_EXT"] == "backports"
require "ruby-next/language"

require "ruby-next/language/rewriters/edge"
require "ruby-next/language/rewriters/proposed"

require "ruby-next/language/runtime"

require_relative "method_reference"
