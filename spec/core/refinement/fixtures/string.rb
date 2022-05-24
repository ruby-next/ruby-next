module RefinementSpecs
  module StringExt
    refine String do
      def decapitalize
        return self if empty?

        "#{self[0].downcase}#{self[1..-1]}"
      end
    end
  end
end
