# frozen_string_literal: true

require_relative "../support/command_testing"

describe "overwrite mode" do
  context "--single-version is not passed" do
    it "prints the missing option error" do
      run_ruby_next(
        "nextify #{File.join(__dir__, "fixtures", "array_in_hash_pattern.rb")} " \
        "--overwrite",
        should_fail: true
      ) do |_status, output, err|
        output.should include(
          "--overwrite must be used with --single-version only"
        )
      end
    end
  end

  context "--single-version is passed" do
    before do
      file_dir = File.join(__dir__, "fixtures", "overwrite")
      original_file_path = File.join(file_dir, "array_in_hash_pattern.rb")
      @original_file_copy_path = File.join(file_dir, "array_in_hash_pattern_copy.rb")
      FileUtils.cp(original_file_path, @original_file_copy_path)
      @transpiled_file_path = File.join(file_dir, "array_in_hash_pattern_transpiled.rb")
    end

    it "overwrites the file" do
      run_ruby_next(
        "nextify #{@original_file_copy_path} " \
        "--overwrite --single-version"
      ) do |_status, output, err|
        FileUtils.compare_file(@original_file_copy_path, @transpiled_file_path).should equal true
      end
    end

    after do
      FileUtils.remove_file(@original_file_copy_path)
    end
  end
end
