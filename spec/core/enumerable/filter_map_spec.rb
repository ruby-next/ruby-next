# source: https://github.com/ruby/ruby/blob/master/spec/ruby/core/enumerable/filter_map_spec.rb

require_relative '../../spec_helper'
require_relative 'fixtures/classes'

ruby_version_is '2.7' do
  describe 'Enumerable#filter_map' do
    before :each do
      @numerous = EnumerableSpecs::Numerous.new(*(1..8).to_a)
    end

    it 'returns an empty array if there are no elements' do
      EnumerableSpecs::Empty.new.filter_map { true }.should == []
    end

    it 'returns an array with truthy results of passing each element to block' do
      @numerous.filter_map { |i| i * 2 if i.even? }.should == [4, 8, 12, 16]
      @numerous.filter_map { |i| i * 2 }.should == [2, 4, 6, 8, 10, 12, 14, 16]
      @numerous.filter_map { 0 }.should == [0, 0, 0, 0, 0, 0, 0, 0]
      @numerous.filter_map { false }.should == []
      @numerous.filter_map { nil }.should == []
    end

    it 'returns an enumerator when no block given' do
      @numerous.filter_map.should be_an_instance_of(Enumerator)
    end

    it 'is chainable' do
      @numerous.filter_map.with_index { |item, i| item * 2 if i > 3 }.should == [10, 12, 14, 16]
    end

    it 'supports lazy' do
      (1..15).lazy.filter_map { |v| v if v % 3 == 0 }.first(3).should == [3, 6, 9]
    end
  end
end
