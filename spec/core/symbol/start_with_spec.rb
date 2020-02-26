# frozen_string_literal: true
# source: https://github.com/ruby/spec/blob/master/core/string/start_with_spec.rb

require_relative '../../spec_helper'

describe "Sybmol#start_with?" do
  it "returns true only if beginning match" do
    s = :hello
    s.start_with?('h').should == true
    s.start_with?('hel').should == true
    s.start_with?('el').should == false
  end

  it "returns true only if any beginning match" do
    :hello.start_with?('x', 'y', 'he', 'z').should == true
  end

  it "returns true if the search string is empty" do
    :hello.start_with?("").should == true
  end

  it "ignores arguments not convertible to string" do
    :hello.start_with?().should == false
    -> { :hello.start_with?(1) }.should raise_error(TypeError)
    -> { :hello.start_with?(["h"]) }.should raise_error(TypeError)
    -> { :hello.start_with?(1, nil, "h") }.should raise_error(TypeError)
  end

  it "uses only the needed arguments" do
    find = mock('h')
    find.should_not_receive(:to_str)
    :hello.start_with?("h",find).should == true
  end

  it "supports regexps" do
    regexp = /[h1]/
    :hello.start_with?(regexp).should == true
  end
end
