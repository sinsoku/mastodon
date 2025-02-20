# frozen_string_literal: true

module Redisable
  # @rbs () -> Redis::Namespace
  def redis
    Thread.current[:redis] ||= RedisConnection.pool.checkout
  end

  # @rbs () -> void
  def with_redis(&block)
    RedisConnection.with(&block)
  end
end
