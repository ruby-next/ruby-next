# frozen_string_literal: true

require_relative "../spec_helper"
require_relative "../support/command_testing"
require "fileutils"

describe "ruby-next nextify" do
  after do
    FileUtils.rm_rf(File.join(__dir__, "dummy", ".rbnext"))
    File.delete(File.join(__dir__, "dummy", ".rbnextrc")) if File.exist?(File.join(__dir__, "dummy", ".rbnextrc"))
  end

  it "generates .rbnext/{2.6, 2.7, 3.0, next} folders with the transpiled files required for each version" do
    run_ruby_next "nextify #{File.join(__dir__, "dummy")} --proposed --edge" do |_status, _output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.6", "transpile_me.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.6", "namespaced", "pattern_matching.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.6", "namespaced", "version.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.6", "namespaced", "endless_nameless.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.7", "transpile_me.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.7", "namespaced", "pattern_matching.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.7", "namespaced", "version.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.7", "namespaced", "endless_nameless.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "3.0", "namespaced", "pattern_matching.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "3.0", "namespaced", "endless_nameless.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "1995.next", "method_reference.rb")).should equal true
    end
  end

  it "generates .rbnext/{2.7, 3.0, next} folders when --min-version is provided" do
    run_ruby_next "nextify #{File.join(__dir__, "dummy")} --proposed --edge --min-version=2.6" do |_status, _output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.6", "transpile_me.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.6", "namespaced", "pattern_matching.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.6", "namespaced", "version.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.6", "namespaced", "endless_nameless.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.7", "transpile_me.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.7", "namespaced", "pattern_matching.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.7", "namespaced", "version.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.7", "namespaced", "endless_nameless.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "3.0", "namespaced", "pattern_matching.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "3.0", "namespaced", "endless_nameless.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "1995.next", "method_reference.rb")).should equal true
    end
  end

  it "generates empty .rbnext folders when nothing to transpile with .keep" do
    run_ruby_next "nextify #{File.join(__dir__, "dummy", "namespaced")} --min-version=3.0" do |_status, _output, err|
      File.exist?(File.join(__dir__, "dummy", "namespaced", ".rbnext", ".keep")).should equal true
    end
  end

  it "removes existing transpiled files if they're no longer need to be transpiled" do
    FileUtils.mkdir_p(File.join(__dir__, "dummy", ".rbnext", "2.7", "namespaced"))
    FileUtils.cp(File.join(__dir__, "dummy", "namespaced", "version.rb"), File.join(__dir__, "dummy", ".rbnext", "2.7", "namespaced", "version.rb"))

    run_ruby_next "nextify #{File.join(__dir__, "dummy")} --proposed --edge --min-version=2.6 -V" do |_status, _output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.7", "transpile_me.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.7", "namespaced", "pattern_matching.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.7", "namespaced", "version.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.7", "namespaced", "endless_nameless.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "3.0", "namespaced", "pattern_matching.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "3.0", "namespaced", "endless_nameless.rb")).should equal false
    end
  end

  it "generates one version if --single-version is provided" do
    run_ruby_next(
      "nextify #{File.join(__dir__, "dummy")} --proposed " \
      "--single-version"
    ) do |_status, _output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "transpile_me.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "namespaced", "endless_nameless.rb")).should equal true
    end
  end

  it "generates .rbnext/custom folder with versions" do
    run_ruby_next(
      "nextify #{File.join(__dir__, "dummy")} --proposed " \
      "--output=#{File.join(__dir__, "dummy", ".rbnext", "custom")}"
    ) do |_status, _output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "custom", "2.7", "transpile_me.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "custom", "2.6", "namespaced", "endless_nameless.rb")).should equal true
    end
  end

  it "generates two version for mixed files (both 2.6 and 2.7 features)" do
    run_ruby_next "nextify #{File.join(__dir__, "dummy")} --proposed" do |_status, _output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.7", "endless_pattern.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.6", "endless_pattern.rb")).should equal true
    end
  end

  it "can generate a single file and store it into a specified path" do
    run_ruby_next(
      "nextify #{File.join(__dir__, "dummy", "transpile_me.rb")} " \
      "-o #{File.join(__dir__, "dummy", ".rbnext", "transpile_me_old.rb")}"
    ) do |_status, _output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "transpile_me_old.rb")).should equal true
      File.read(File.join(__dir__, "dummy", ".rbnext", "transpile_me_old.rb")).should include("deconstruct_keys([:status])")
    end
  end

  it "can generate a single file with the specified min version and store it into a specified path" do
    run_ruby_next(
      "nextify #{File.join(__dir__, "dummy", "endless_pattern.rb")} " \
      "-o #{File.join(__dir__, "dummy", ".rbnext", "endless_pattern_26.rb")} --min-version=2.6"
    ) do |_status, _output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "endless_pattern_26.rb")).should equal true
      File.read(File.join(__dir__, "dummy", ".rbnext", "endless_pattern_26.rb")).should include("(1..)")
    end
  end

  it "can generate multiple files from a single file and print logs" do
    run_ruby_next(
      "nextify #{File.join(__dir__, "dummy", "endless_pattern.rb")} " \
      "-V"
    ) do |_status, _output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.6", "endless_pattern.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.7", "endless_pattern.rb")).should equal true
    end
  end

  it "fails when syntax is unsupported and not enabled explicitly" do
    run_ruby_next(
      "nextify #{File.join(__dir__, "..", "optional", "integration", "fixtures", "method_reference.rb")} " \
      "-o #{File.join(__dir__, "dummy", ".rbnext", "method_reference_old.rb")}",
      should_fail: true
    ) do |status, output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "method_reference_old.rb")).should equal false
    end
  end

  it "generates one version if --rewrite is provided" do
    run_ruby_next(
      "nextify #{File.join(__dir__, "dummy")} --proposed " \
      "--rewrite=endless-range --rewrite=pattern-matching"
    ) do |_status, _output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "match_pattern.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "method_reference.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "transpile_me.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "endless_pattern.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "namespaced", "endless_nameless.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "namespaced", "pattern_matching.rb")).should equal true
    end
  end

  it "returns error if --rewrite is provided with wrong rewriter" do
    run_ruby_next(
      "nextify #{File.join(__dir__, "dummy")} " \
      "--rewrite=endless-method-new",
      env: {"RUBY_NEXT_EDGE" => "0", "RUBY_NEXT_PROPOSED" => "0"},
      should_fail: true
    ) do |_status, output, err|
      output.should include("Rewriters not found: endless-method-new")
    end
  end

  it "generates one version if --rewrite is provided with rewriter from edge along with --edge option" do
    run_ruby_next(
      "nextify #{File.join(__dir__, "dummy")} " \
      "--rewrite=endless-method --edge",
      env: {"RUBY_NEXT_EDGE" => "0", "RUBY_NEXT_PROPOSED" => "1"}
    ) do |_status, _output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "namespaced", "pattern_matching.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "match_pattern.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "method_reference.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "transpile_me.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "endless_pattern.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "namespaced", "endless_nameless.rb")).should equal false
    end
  end

  it "generates one version if --rewrite is provided with rewriter from proposed along with --proposed option" do
    run_ruby_next(
      "nextify #{File.join(__dir__, "dummy")} " \
      "--rewrite=method-reference --proposed",
      env: {"RUBY_NEXT_EDGE" => "0", "RUBY_NEXT_PROPOSED" => "0"}
    ) do |_status, _output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "match_pattern.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "method_reference.rb")).should equal true
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "transpile_me.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "endless_pattern.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "namespaced", "endless_nameless.rb")).should equal false
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "namespaced", "pattern_matching.rb")).should equal false
    end
  end

  it "returns error if --rewrite is provided along with --min-version" do
    run_ruby_next(
      "nextify #{File.join(__dir__, "dummy")} " \
      "--rewrite=endless-range --min-version=2.5",
      should_fail: true
    ) do |_status, output, err|
      output.should include("--rewrite cannot be used with --min-version simultaneously")
    end
  end

  it "supports --no-refine" do
    run_ruby_next(
      "nextify #{File.join(__dir__, "dummy", "transpile_me.rb")} " \
      "--no-refine -o #{File.join(__dir__, "dummy", ".rbnext", "transpile_me_old.rb")}"
    ) do |_status, _output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "transpile_me_old.rb")).should equal true
      File.read(File.join(__dir__, "dummy", ".rbnext", "transpile_me_old.rb")).should_not include("using RubyNext")
    end
  end

  it "--transpile-mode=rewrite" do
    run_ruby_next(
      "nextify #{File.join(__dir__, "dummy", "endless_pattern.rb")} " \
      "--transpile-mode=rewrite -o #{File.join(__dir__, "dummy", ".rbnext", "endless_pattern_old.rb")}"
    ) do |_status, _output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "endless_pattern_old.rb")).should equal true
      File.read(File.join(__dir__, "dummy", ".rbnext", "endless_pattern_old.rb")).lines.size.should equal(
        File.read(File.join(__dir__, "dummy", "endless_pattern.rb")).lines.size
      )
    end
  end

  it "--proposed" do
    run_ruby_next(
      "nextify #{File.join(__dir__, "..", "integration", "fixtures", "method_reference.rb")} --proposed " \
      "-o #{File.join(__dir__, "dummy", ".rbnext", "method_reference_old.rb")}",
      env: {"RUBY_NEXT_PROPOSED" => "0"}
    ) do |_status, _output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "method_reference_old.rb")).should equal true
      File.read(File.join(__dir__, "dummy", ".rbnext", "method_reference_old.rb")).should include("JSON.method(:parse)")
    end
  end

  it "--proposed is not set" do
    run_ruby_next(
      "nextify #{File.join(__dir__, "..", "integration", "fixtures", "method_reference.rb")} " \
      "-o #{File.join(__dir__, "dummy", ".rbnext", "method_reference_old.rb")}",
      env: {"RUBY_NEXT_PROPOSED" => "0"},
      should_fail: true
    ) do |_status, _output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "method_reference_old.rb")).should equal false
    end
  end

  it "--edge" do
    run_ruby_next(
      "nextify #{File.join(__dir__, "..", "integration", "fixtures", "endless_def.rb")} --edge " \
      "--transpile-mode=rewrite --min-version=2.7 " \
      "-o #{File.join(__dir__, "dummy", ".rbnext", "endless_def_old.rb")}",
      env: {"RUBY_NEXT_EDGE" => "0"}
    ) do |_status, _output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "endless_def_old.rb")).should equal true
      File.read(File.join(__dir__, "dummy", ".rbnext", "endless_def_old.rb")).should include("def greet(val) ;")
    end
  end

  # rubocop:disable  Lint/UnreachableCode
  it "--edge is not set" do
    # TODO: add edge features
    next skip

    run_ruby_next(
      "nextify #{File.join(__dir__, "..", "integration", "fixtures", "endless_def.rb")} " \
      "--transpile-mode=rewrite --min-version=2.7 " \
      "-o #{File.join(__dir__, "dummy", ".rbnext", "endless_def_old.rb")}",
      env: {"RUBY_NEXT_EDGE" => "0"}
    ) do |_status, _output, err|
      File.exist?(File.join(__dir__, "dummy", ".rbnext", "endless_def_old.rb")).should equal false
    end
  end
  # rubocop:enable  Lint/UnreachableCode

  it "--dry-run" do
    run_ruby_next "nextify #{File.join(__dir__, "dummy")} --proposed --dry-run" do |_status, output, err|
      out_path = File.join(__dir__, "dummy", ".rbnext", "2.7", "transpile_me.rb")
      output.should include("[DRY RUN] Generated: #{out_path}")
      File.directory?(File.join(__dir__, "dummy", ".rbnext", "2.7")).should equal false
      File.exist?(out_path).should equal false
    end
  end

  it "with .rbnextrc" do
    Dir.chdir(File.join(__dir__, "dummy")) do
      File.write(".rbnextrc",
        <<~YML
          nextify: |
            --min-version=2.6
            --transpile-mode=rewrite
            --proposed
        YML
      )

      run_ruby_next("nextify #{File.join(__dir__, "dummy")}", chdir: Dir.pwd) do |_status, output, err|
        File.directory?(File.join(__dir__, "dummy", ".rbnext", "2.6")).should equal false
        File.directory?(File.join(__dir__, "dummy", ".rbnext", "2.7")).should equal true

        File.exist?(File.join(__dir__, "dummy", ".rbnext", "2.7", "endless_pattern.rb")).should equal true
        File.read(File.join(__dir__, "dummy", ".rbnext", "2.7", "endless_pattern.rb")).lines.size.should equal(
          File.read(File.join(__dir__, "dummy", "endless_pattern.rb")).lines.size
        )
      end
    end
  end

  it "--list-rewriters" do
    run_ruby_next(
      "nextify --list-rewriters",
      env: {"RUBY_NEXT_PROPOSED" => "0", "RUBY_NEXT_EDGE" => "0"}
    ) do |_status, output, err|
      output.should include('args-forward ("obj = Object.new; def obj.foo(...) super(...); end")')
      output.should include('args-forward-leading ("obj = Object.new; def obj.foo(...) super(1, ...); end")')
      output.should include('numbered-params ("proc { _1 }.call(1)")')
      output.should include('pattern-matching ("case 0; in 0; true; else; 1; end")')
      output.should include('pattern-matching-find-pattern ("case 0; in [*,0,*]; true; else; 1; end")')
      output.should include('endless-range ("[0, 1][1..]")')
      output.should include('endless-method ("obj = Object.new; def obj.foo() = 42")')
      output.should_not include('method-reference ("Language.:transform")')
    end
  end

  it "--list-rewriters --edge" do
    run_ruby_next(
      "nextify --list-rewriters --edge",
      env: {"RUBY_NEXT_PROPOSED" => "0", "RUBY_NEXT_EDGE" => "0"}
    ) do |_status, output, err|
      output.should include('endless-method ("obj = Object.new; def obj.foo() = 42")')
    end
  end

  it "--list-rewriters --proposed" do
    run_ruby_next(
      "nextify --list-rewriters --proposed",
      env: {"RUBY_NEXT_PROPOSED" => "0", "RUBY_NEXT_EDGE" => "0"}
    ) do |_status, output, err|
      output.should include('method-reference ("Language.:transform")')
    end
  end

  context "with --overwrite" do
    before do
      @original_path = File.join(__dir__, "dummy", "transpile_me.rb")
      @target_path = File.join(__dir__, "dummy", "overwrite_me.rb")
      @transpiled_path = File.join(__dir__, "dummy", "transpiled.rb")
      FileUtils.cp(@original_path, @target_path)
    end

    after do
      File.delete(@target_path) if File.file?(@target_path)
      File.delete(@transpiled_path) if File.file?(@transpiled_path)
    end

    it "overwrites original file when --single-version is specified" do
      run_ruby_next(
        "nextify #{@target_path} --single-version -o #{@transpiled_path}"
      ) do
        run_ruby_next(
          "nextify #{@target_path} " \
      "--single-version --overwrite"
        ) do |_status, _output, _err|
          FileUtils.compare_file(@original_path, @target_path).should_not equal true
          FileUtils.compare_file(@transpiled_path, @target_path).should equal true
        end
      end
    end

    it "overwrites original file when --rewrite is specified" do
      run_ruby_next(
        "nextify #{@target_path} " \
        "--rewrite=endless-range --rewrite=pattern-matching " \
        "-o #{@transpiled_path}"
      ) do
        run_ruby_next(
          "nextify #{@target_path} " \
          "--rewrite=endless-range --rewrite=pattern-matching --overwrite"
        ) do |_status, _output, _err|
          FileUtils.compare_file(@original_path, @target_path).should_not equal true
          FileUtils.compare_file(@transpiled_path, @target_path).should equal true
        end
      end
    end

    it "warns if no --single-version or --rewrite is provided" do
      run_ruby_next(
        "nextify #{@target_path} --overwrite",
        should_fail: true
      ) do |_status, output, _err|
        output.should include("--overwrite only works with")
      end
    end
  end
end
