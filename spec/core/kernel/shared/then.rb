# source: https://github.com/ruby/spec/blob/master/core/kernel/shared/then.rb 

# NOTE: `send(@method)` was changed to the direct `then` call to make it work in JRuby.
#       See https://github.com/jruby/jruby/issues/5945
describe :kernel_then, shared: true do
  it "yields self" do
    object = Object.new
    object.then { |o| o.should equal object }
  end

  it "returns the block return value" do
    object = Object.new
    object.then { 42 }.should equal 42
  end

  it "returns a sized Enumerator when no block given" do
    object = Object.new
    enum = object.then
    enum.should be_an_instance_of Enumerator
    enum.size.should equal 1
    enum.peek.should equal object
    enum.first.should equal object
  end
end
