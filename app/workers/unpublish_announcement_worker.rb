# frozen_string_literal: true

class UnpublishAnnouncementWorker
  include Sidekiq::Worker
  include Redisable

  # @rbs (nil) -> nil
  def perform(announcement_id)
    payload = Oj.dump(event: :'announcement.delete', payload: announcement_id.to_s)

    FeedManager.instance.with_active_accounts do |account|
      redis.publish("timeline:#{account.id}", payload) if redis.exists?("subscribed:timeline:#{account.id}")
    end
  end
end
