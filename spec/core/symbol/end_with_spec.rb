# frozen_string_literal: true
# source: https://github.com/ruby/spec/blob/master/core/string/end_with_spec.rb

require_relative '../../spec_helper'

describe "Symbol#end_with?" do
  it "returns true only if ends match" do
    s = :hello
    s.end_with?('o').should == true
    s.end_with?('llo').should == true
  end

  it 'returns false if the end does not match' do
    s = :hello
    s.end_with?('ll').should == false
  end

  it "returns true if the search string is empty" do
    :hello.end_with?("").should == true
  end

  it "returns true only if any ending match" do
    :hello.end_with?('x', 'y', 'llo', 'z').should == true
  end

  it "converts its argument using :to_str" do
    s = :hello
    find = mock('o')
    find.should_receive(:to_str).and_return("o")
    s.end_with?(find).should == true
  end

  it "ignores arguments not convertible to string" do
    :hello.end_with?().should == false
    -> { :hello.end_with?(1) }.should raise_error(TypeError)
    -> { :hello.end_with?(["o"]) }.should raise_error(TypeError)
    -> { :hello.end_with?(1, nil, "o") }.should raise_error(TypeError)
  end

  it "uses only the needed arguments" do
    find = mock('h')
    find.should_not_receive(:to_str)
    :hello.end_with?("o",find).should == true
  end
end
