# source: https://github.com/ruby/spec/blob/master/core/hash/merge_spec.rb

# NOTE: only multi args specs are copied
require_relative '../../spec_helper'

describe "Hash#merge" do
  ruby_version_is "2.6" do
    it "accepts multiple hashes" do
      result = { a: 1 }.merge({ b: 2 }, { c: 3 }, { d: 4 })
      result.should == { a: 1, b: 2, c: 3, d: 4 }
    end

    it "accepts zero arguments and returns a copy of self" do
      hash = { a: 1 }
      merged = hash.merge

      merged.should eql(hash)
      merged.should_not equal(hash)
    end
  end
end
