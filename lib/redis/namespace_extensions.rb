# frozen_string_literal: true

class Redis
  module NamespaceExtensions
    # @rbs (*untyped, **untyped) -> bool
    def exists?(...)
      call_with_namespace('exists?', ...)
    end

    def with
      yield self
    end
  end
end

Redis::Namespace::COMMANDS['exists?'] = [:first]
Redis::Namespace.prepend(Redis::NamespaceExtensions)
