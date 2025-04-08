# frozen_string_literal: true

module Redisable
  # @rbs () -> Redis::Namespace
  def redis
    Thread.current[:redis] ||= RedisConnection.pool.checkout
  end

  # @rbs () -> (bool | Account | String | Follow | Array[untyped] | Integer | Status | Backup | Web::PushSubscription | PollVote)?
  def with_redis(&block)
    RedisConnection.with(&block)
  end
end
