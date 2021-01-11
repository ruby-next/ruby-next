describe "A number literal" do
  it "can be an integer literal with trailing 'r' to represent a Rational" do
    3r.should == Rational(3, 1)
    -3r.should == Rational(-3, 1)
  end

  it "can be a float literal with trailing 'r' to represent a Rational" do
    0.0174532925199432r.should == Rational(174532925199432, 10000000000000000)
  end

  it "can be an bignum literal with trailing 'r' to represent a Rational" do
    1111111111111111111111111111111111111111111111r.should == Rational(1111111111111111111111111111111111111111111111, 1)
    -1111111111111111111111111111111111111111111111r.should == Rational(-1111111111111111111111111111111111111111111111, 1)
  end

  it "can be a decimal literal with trailing 'r' to represent a Rational" do
    0.3r.should == Rational(3, 10)
    -0.3r.should == Rational(-3, 10)
  end

  it "can be a hexadecimal literal with trailing 'r' to represent a Rational" do
    0xffr.should == Rational(255, 1)
    -0xffr.should == Rational(-255, 1)
  end

  it "can be an octal literal with trailing 'r' to represent a Rational"  do
    042r.should == Rational(34, 1)
    -042r.should == Rational(-34, 1)
  end

  it "can be a binary literal with trailing 'r' to represent a Rational" do
    0b1111r.should == Rational(15, 1)
    -0b1111r.should == Rational(-15, 1)
  end

  it "can be an integer literal with trailing 'i' to represent a Complex" do
    5i.should == Complex(0, 5)
    -5i.should == Complex(0, -5)
  end

  it "can be a decimal literal with trailing 'i' to represent a Complex" do
    0.6i.should == Complex(0, 0.6)
    -0.6i.should == Complex(0, -0.6)
  end

  it "can be a hexadecimal literal with trailing 'i' to represent a Complex" do
    0xffi.should == Complex(0, 255)
    -0xffi.should == Complex(0, -255)
  end

  it "can be a octal literal with trailing 'i' to represent a Complex" do
    042i.should == Complex(0, 34)
    -042i.should == Complex(0, -34)
  end

  it "can be a binary literal with trailing 'i' to represent a Complex" do
    0b1110i.should == Complex(0, 14)
    -0b1110i.should == Complex(0, -14)
  end
end
