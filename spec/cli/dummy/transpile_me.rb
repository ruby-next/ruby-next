class A
  def self.transform(val)
    JSON.:parse.call %q({"status": "ok"})
  end
end
