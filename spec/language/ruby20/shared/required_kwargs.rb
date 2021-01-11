describe "required keyword arguments" do
  it "raises ArgumentError if missing" do
    klass = Class.new do
      def foo(bar:, baz: "boom")
        "#{bar} #{baz}"
      end
    end

    obj = klass.new

    obj.foo(bar: "x", baz: "y").should == "x y"

    -> {
      obj.foo(baz: "y")
    }.should raise_error(ArgumentError, /missing keyword: :?bar/)
  end
end
