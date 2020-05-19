# frozen_string_literal: true

require_relative "../support/command_testing"

describe "setup load path" do
  after do
    FileUtils.rm_rf(File.join(__dir__, "fixtures", "lib", ".rbnext_test")) if
      File.directory?(File.join(__dir__, "fixtures", "lib", ".rbnext_test"))
  end

  it "loads correct file versions" do
    next skip if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.8")
    run_ruby(
      "-I#{File.join(__dir__, "fixtures", "lib")} " \
      "-r txen " \
      "-e 'puts [Txen.call(\"ace\", \"ace\"), Txen.call(\"ace\", \"4\", \"5\")].join(\";\")'"
    ) do |_status, output, _err|
      output.should include("failed;ok")
    end
  end

  it "ignores transpiled files if runtime mode is enabled for lib" do
    run_ruby(
      "-I#{File.join(__dir__, "fixtures", "lib")} " \
      "-r txen_runtime " \
      "-e 'puts [Txen.call(\"ace\", \"ace\"), Txen.call(\"ace\", \"4\", \"5\")].join(\";\")'"
    ) do |_status, output, _err|
      output.should include("ok;ok")
    end
  end

  it "autotranspiles files is rbnext_dir is missing" do
    run_ruby(
      "-I#{File.join(__dir__, "fixtures", "lib")} " \
      "-r txen_source " \
      "-e 'puts [Txen.call(\"ace\", \"ace\"), Txen.call(\"ace\", \"4\", \"5\")].join(\";\")'"
    ) do |_status, output, _err|
      output.should include("ok;ok")
      File.directory?(File.join(__dir__, "fixtures", "lib", ".rbnext_test")).should equal true
      # .rbnextrc is preserved
      File.exist?(File.join(__dir__, "fixtures", "lib", ".rbnext_test", "2.7", "txen", "cards.rb")).should equal true
      File.read(File.join(__dir__, "fixtures", "lib", ".rbnext_test", "2.7", "txen", "cards.rb")).lines.size.should equal(
        File.read(File.join(__dir__, "fixtures", "lib", "txen", "cards.rb")).lines.size
      )
    end
  end
end
