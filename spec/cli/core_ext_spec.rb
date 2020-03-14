# frozen_string_literal: true

require_relative "../support/command_testing"
require "fileutils"

using CommandTesting

describe "ruby-next core_ext" do
  before do
    @out_path = File.join(__dir__, "dummy", "core_ext.rb")
  end

  after do
    File.delete(@out_path) if File.exist?(@out_path)
  end

  it "-l" do
    run_ruby_next("core_ext -l") do |_status, output, err|
      output.should include("2.6 extensions:")
      output.should include("- KernelThen")
      output.should include("- ProcCompose")
      output.should include("2.7 extensions:")
      output.should include("- NoMatchingPatternError")
      output.should include("- EnumerableFilterMap")
      output.should include("- ArrayDeconstruct")
      output.should include("- HashDeconstructKeys")
    end
  end

  it "-l --min-version" do
    run_ruby_next("core_ext -l --min-version 2.6") do |_status, output, err|
      output.should_not include("2.6 extensions:")
      output.should_not include("- KernelThen")
      output.should_not include("- ProcCompose")
      output.should include("2.7 extensions:")
      output.should include("- EnumerableFilterMap")
      output.should include("- ArrayDeconstruct")
      output.should include("- HashDeconstructKeys")
    end
  end

  it "--min-version 2.5" do
    run_ruby_next("core_ext --min-version 2.5 -o #{@out_path}") do |_status, _output, err|
      File.exist?(@out_path).should equal true
      File.read(@out_path).tap do |contents|
        contents.should include("alias then yield_self")
        contents.should include("def merge")
        contents.should include("def filter_map")
        contents.should include("def deconstruct_keys")
      end
    end
  end

  it "--min-version 2.6" do
    run_ruby_next("core_ext --min-version 2.6 -o #{@out_path}") do |_status, _output, err|
      File.exist?(@out_path).should equal true
      File.read(@out_path).tap do |contents|
        contents.should_not include("alias then yield_self")
        contents.should include("def filter_map")
        contents.should include("def deconstruct_keys")
      end
    end
  end

  it "-n <name_pattern_with_method>" do
    run_ruby_next("core_ext -n deconstruct -o #{@out_path}") do |_status, _output, err|
      File.exist?(@out_path).should equal true
      File.read(@out_path).tap do |contents|
        contents.should_not include("alias then yield_self")
        contents.should_not include("def filter_map")
        contents.should include("def deconstruct_keys")
        contents.should include("def deconstruct")
      end
    end
  end

  it "-n <name_pattern_with_class_method>" do
    run_ruby_next("core_ext -n ArrayDeconstruct -o #{@out_path}") do |_status, _output, err|
      File.exist?(@out_path).should equal true
      File.read(@out_path).tap do |contents|
        contents.should_not include("alias then yield_self")
        contents.should_not include("def filter_map")
        contents.should_not include("def deconstruct_keys")
        contents.should include("def deconstruct")
      end
    end
  end

  it "-n <first> -n <second>" do
    run_ruby_next("core_ext -n ArrayDeconstruct -n EnumerableFilterMap -o #{@out_path}") do |_status, _output, err|
      File.exist?(@out_path).should equal true
      File.read(@out_path).tap do |contents|
        contents.should_not include("alias then yield_self")
        contents.should include("def filter_map")
        contents.should_not include("def deconstruct_keys")
        contents.should include("def deconstruct")
      end
    end
  end

  it "contains the command and Ruby Next version" do
    run_ruby_next("core_ext --min-version 2.5 -o #{@out_path}") do |_status, _output, err|
      File.exist?(@out_path).should equal true
      File.read(@out_path).tap do |contents|
        contents.should include("Generated by Ruby Next v#{RubyNext::VERSION} using the following command:")
        contents.should include("ruby-next core_ext --min-version 2.5 -o #{@out_path}")
      end
    end
  end
end
