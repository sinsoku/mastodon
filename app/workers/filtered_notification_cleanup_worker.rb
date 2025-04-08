# frozen_string_literal: true

class FilteredNotificationCleanupWorker
  include Sidekiq::Worker

  # @rbs (Integer, Integer) -> Integer
  def perform(account_id, from_account_id)
    Notification.where(account_id: account_id, from_account_id: from_account_id, filtered: true).in_batches(order: :desc).delete_all
  end
end
