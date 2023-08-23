# frozen_string_literal: true

module RequireHooks
  module Bootsnap
    module CompileCacheExt
      def input_to_storage(source, path, *)
        new_contents = RequireHooks.perform_source_transform(path)
        hijacked = RequireHooks.try_hijack_load(path, new_contents)

        if hijacked
          raise TypeError, "Unsupported bytecode format for #{path}: #{hijack.class}" unless hijacked.is_a?(::RubyVM::InstructionSequence)
          return hijacked.to_binary
        elsif new_contents
          return RubyVM::InstructionSequence.compile(new_contents, path, path, 1).to_binary
        end

        super
      rescue SyntaxError, TypeError
        raise Bootsnap::CompileCache::Uncompilable
      end
    end

    module LoadIseqExt
      # Around hooks must be performed every time we trigger a file load, even if
      # the file is already cached.
      def load_iseq(path)
        RequireHooks.run_around_load_callbacks(path) { super }
      end
    end
  end
end

Bootsnap::CompileCache::ISeq.singleton_class.prepend(RequireHooks::Bootsnap::CompileCacheExt)
RubyVM::InstructionSequence.singleton_class.prepend(RequireHooks::Bootsnap::LoadIseqExt)
