# source: https://github.com/ruby/spec/blob/master/core/time/ceil_spec.rb

# NOTE: required changes
#  - Use different @time precision for JRuby and skip higher precision tests
#  - Skip class test in JRuby
#  - Fix timezone spec to assert outside of block

require_relative '../../spec_helper'

ruby_version_is "2.7" do
  describe "Time#ceil" do
    before do
      # Probably, related to https://github.com/jruby/jruby/issues/5558
      if defined?(JRUBY_VERSION)
        @time = Time.utc(2010, 3, 30, 5, 43, "25.0125".to_r)
      else
        @time = Time.utc(2010, 3, 30, 5, 43, "25.0123456789".to_r)
      end
    end

    it "defaults to ceiling to 0 places" do
      @time.ceil.should == Time.utc(2010, 3, 30, 5, 43, 26.to_r)
    end

    it "ceils to 0 decimal places with an explicit argument" do
      @time.ceil(0).should == Time.utc(2010, 3, 30, 5, 43, 26.to_r)
    end

    it "ceils to 2 decimal places with an explicit argument" do
      @time.ceil(2).should == Time.utc(2010, 3, 30, 5, 43, "25.02".to_r)
    end

    it "ceils to 4 decimal places with an explicit argument" do
      next skip if defined?(JRUBY_VERSION)
      @time.ceil(4).should == Time.utc(2010, 3, 30, 5, 43, "25.0124".to_r)
    end

    it "ceils to 7 decimal places with an explicit argument" do
      next skip if defined?(JRUBY_VERSION)
      @time.ceil(7).should == Time.utc(2010, 3, 30, 5, 43, "25.0123457".to_r)
    end

    it "returns an instance of Time, even if #ceil is called on a subclass" do
      # JRuby returns subclass; probably, related to https://github.com/jruby/jruby/issues/5125
      next skip if defined?(JRUBY_VERSION)
      subclass = Class.new(Time)
      instance = subclass.at(0)
      instance.class.should equal subclass
      instance.ceil.should be_an_instance_of(Time)
    end

    it "copies own timezone to the returning value" do
      @time.zone.should == @time.ceil.zone


      time = with_timezone "JST-9" do
        Time.at 0, 1
      end

      time.zone.should == time.ceil.zone
    end
  end
end
