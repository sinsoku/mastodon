# frozen_string_literal: true

class PushUpdateWorker
  include Sidekiq::Worker
  include Redisable

  # @rbs (Integer?, Integer?, ?nil, ?Hash[untyped, untyped]) -> void
  def perform(account_id, status_id, timeline_id = nil, options = {})
    @status      = Status.find(status_id)
    @account_id  = account_id
    @timeline_id = timeline_id || "timeline:#{account_id}"
    @options     = options.symbolize_keys

    render_payload!
    publish!
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  # @rbs () -> void
  def render_payload!
    @payload = StatusCacheHydrator.new(@status).hydrate(@account_id)
  end

  # @rbs () -> void
  def message
    Oj.dump(
      event: update? ? :'status.update' : :update,
      payload: @payload
    )
  end

  # @rbs () -> void
  def publish!
    redis.publish(@timeline_id, message)
  end

  # @rbs () -> void
  def update?
    @options[:update]
  end
end
