# frozen_string_literal: true
using RubyNext;
def main(val)
  case; when ((__m__ = JSON.parse(val, symbolize_names: true))) && false 
  when (((age,) = nil) || (__m__.respond_to?(:deconstruct_keys) && (((__m_hash__ = __m__.deconstruct_keys([:name, :children])) || true) && (Hash === __m_hash__ || Kernel.raise(TypeError, "#deconstruct_keys must return Hash"))) && ((__m_hash__.key?(:name) && __m_hash__.key?(:children)) && (("Alice" === __m_hash__[:name]) && (__m_hash__[:children].respond_to?(:deconstruct) && (((__m_hash__k0__ = __m_hash__[:children].deconstruct) || true) && (Array === __m_hash__k0__ || Kernel.raise(TypeError, "#deconstruct must return Array"))) && (1 == __m_hash__k0__.size) && (__m_hash__k0__[0].respond_to?(:deconstruct_keys) && (((__m_hash__k0__0__ = __m_hash__k0__[0].deconstruct_keys([:name, :age])) || true) && (Hash === __m_hash__k0__0__ || Kernel.raise(TypeError, "#deconstruct_keys must return Hash"))) && ((__m_hash__k0__0__.key?(:name) && __m_hash__k0__0__.key?(:age)) && (("Bob" === __m_hash__k0__0__[:name]) && ((age = __m_hash__k0__0__[:age]) || true)))))))))
    p "Bob age is #{age}"
  when true
    p "No Alice"; else; Kernel.raise(NoMatchingPatternError, __m__.inspect)
  end
end

main(ARGV[0]) if ARGV[0]
