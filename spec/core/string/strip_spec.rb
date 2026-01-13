require_relative '../../spec_helper'
require_relative 'fixtures/classes'

describe "String#strip with selectors" do
  it "returns a copy with leading and trailing whitespace removed when no arguments given" do
    "  hello  ".strip.should == "hello"
    "\tgoodbye\r\n".strip.should == "goodbye"
  end

  it "strips specified characters from both ends" do
    "---abc+++".strip("-+").should == "abc"
    "+++abc---".strip("-+").should == "abc"
    "+-+abc-+-".strip("-+").should == "abc"
  end

  it "returns an empty string when all characters match" do
    "---+++".strip("-+").should == ""
  end

  it "strips specified characters only, leaving other whitespace" do
    "---abc   ".strip("-").should == "abc   "
    "   abc+++".strip("+").should == "   abc"
  end

  it "supports multibyte characters" do
    "あああabcいいい".strip("あい").should == "abc"
    "いいいabcあああ".strip("あい").should == "abc"
  end

  it "handles NUL characters correctly" do
    "---abc\0--".strip("-").should == "abc\0"
    "--\0abc---".strip("-").should == "\0abc"
  end

  it "returns a copy of self when no characters match" do
    "abc".strip("-+").should == "abc"
    "abc".strip("").should == "abc"
  end

  it "supports character ranges" do
    "012abc345".strip("0-9").should == "abc"
  end

  it "supports negated character classes with ^" do
    "012abc345".strip("^a-z").should == "abc"
  end

  it "supports multiple character selectors" do
    "01234abc56789".strip("0-9", "^4-6").should == "4abc56"
  end

  it "does not modify the original string" do
    str = "---abc+++"
    str.strip("-+")
    str.should == "---abc+++"
  end
end

describe "String#strip! with selectors" do
  it "modifies self in place and returns self when characters are removed" do
    str = "---abc+++"
    str.strip!("-+").should equal(str)
    str.should == "abc"
  end

  it "modifies self correctly for different patterns" do
    str = "+++abc---"
    str.strip!("-+").should equal(str)
    str.should == "abc"
  end

  it "returns nil when no changes are made" do
    str = "abc"
    str.strip!("-+").should be_nil
    str.should == "abc"
  end

  it "supports multibyte characters" do
    str = "あああabcいいい"
    str.strip!("あい").should equal(str)
    str.should == "abc"
  end
end

describe "String#lstrip with selectors" do
  it "returns a copy with leading whitespace removed when no arguments given" do
    "  hello  ".lstrip.should == "hello  "
  end

  it "strips specified characters from the left side only" do
    "---abc+++".lstrip("-").should == "abc+++"
    "+++abc---".lstrip("+").should == "abc---"
    "---abc".lstrip("-").should == "abc"
  end

  it "returns an empty string when all characters match" do
    "---".lstrip("-").should == ""
  end

  it "supports multibyte characters" do
    "あああabcいいい".lstrip("あ").should == "abcいいい"
  end

  it "handles NUL characters correctly" do
    "--\0abc+++".lstrip("-").should == "\0abc+++"
  end

  it "returns a copy of self when no characters match" do
    "abc".lstrip("-").should == "abc"
  end

  it "supports character ranges" do
    "012abc345".lstrip("0-9").should == "abc345"
  end

  it "supports multiple character selectors" do
    "01234abc56789".lstrip("0-9", "^4-6").should == "4abc56789"
  end

  it "does not modify the original string" do
    str = "---abc+++"
    str.lstrip("-")
    str.should == "---abc+++"
  end
end

describe "String#lstrip! with selectors" do
  it "modifies self in place and returns self when characters are removed" do
    str = "---abc+++"
    str.lstrip!("-").should equal(str)
    str.should == "abc+++"
  end

  it "returns nil when no changes are made" do
    str = "abc"
    str.lstrip!("-").should be_nil
    str.should == "abc"
  end
end

describe "String#rstrip with selectors" do
  it "returns a copy with trailing whitespace removed when no arguments given" do
    "  hello  ".rstrip.should == "  hello"
  end

  it "strips specified characters from the right side only" do
    "---abc+++".rstrip("+").should == "---abc"
    "+++abc---".rstrip("-").should == "+++abc"
    "abc+++".rstrip("+").should == "abc"
  end

  it "returns an empty string when all characters match" do
    "+++".rstrip("+").should == ""
  end

  it "supports multibyte characters" do
    "あああabcいいい".rstrip("い").should == "あああabc"
  end

  it "handles NUL characters correctly" do
    "---abc\0++".rstrip("+").should == "---abc\0"
  end

  it "returns a copy of self when no characters match" do
    "abc".rstrip("-").should == "abc"
  end

  it "supports character ranges" do
    "012abc345".rstrip("0-9").should == "012abc"
  end

  it "supports multiple character selectors" do
    "01234abc56789".rstrip("0-9", "^4-6").should == "01234abc56"
  end

  it "does not modify the original string" do
    str = "---abc+++"
    str.rstrip("+")
    str.should == "---abc+++"
  end
end

describe "String#rstrip! with selectors" do
  it "modifies self in place and returns self when characters are removed" do
    str = "---abc+++"
    str.rstrip!("+").should equal(str)
    str.should == "---abc"
  end

  it "returns nil when no changes are made" do
    str = "abc"
    str.rstrip!("+").should be_nil
    str.should == "abc"
  end
end
