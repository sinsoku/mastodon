# frozen_string_literal: true

# == Schema Information
#
# Table name: relays
#
#  id                 :bigint(8)        not null, primary key
#  inbox_url          :string           default(""), not null
#  follow_activity_id :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  state              :integer          default("idle"), not null
#

class Relay < ApplicationRecord
  validates :inbox_url, presence: true, uniqueness: true, url: true, if: :will_save_change_to_inbox_url?

  enum :state, { idle: 0, pending: 1, accepted: 2, rejected: 3 }

  scope :enabled, -> { accepted }

  normalizes :inbox_url, with: ->(inbox_url) { inbox_url.strip }

  before_destroy :ensure_disabled

  alias enabled? accepted?

  # @rbs () -> void
  def enable!
    activity_id = ActivityPub::TagManager.instance.generate_uri_for(nil)
    payload     = Oj.dump(follow_activity(activity_id))

    update!(state: :pending, follow_activity_id: activity_id)
    DeliveryFailureTracker.reset!(inbox_url)
    ActivityPub::DeliveryWorker.perform_async(payload, some_local_account.id, inbox_url)
  end

  # @rbs () -> void
  def disable!
    activity_id = ActivityPub::TagManager.instance.generate_uri_for(nil)
    payload     = Oj.dump(unfollow_activity(activity_id))

    update!(state: :idle, follow_activity_id: nil)
    DeliveryFailureTracker.reset!(inbox_url)
    ActivityPub::DeliveryWorker.perform_async(payload, some_local_account.id, inbox_url)
  end

  private

  # @rbs (URI::HTTPS) -> Hash[untyped, untyped]
  def follow_activity(activity_id)
    {
      '@context': ActivityPub::TagManager::CONTEXT,
      id: activity_id,
      type: 'Follow',
      actor: ActivityPub::TagManager.instance.uri_for(some_local_account),
      object: ActivityPub::TagManager::COLLECTIONS[:public],
    }
  end

  # @rbs (URI::HTTPS) -> Hash[untyped, untyped]
  def unfollow_activity(activity_id)
    {
      '@context': ActivityPub::TagManager::CONTEXT,
      id: activity_id,
      type: 'Undo',
      actor: ActivityPub::TagManager.instance.uri_for(some_local_account),
      object: {
        id: follow_activity_id,
        type: 'Follow',
        actor: ActivityPub::TagManager.instance.uri_for(some_local_account),
        object: ActivityPub::TagManager::COLLECTIONS[:public],
      },
    }
  end

  # @rbs () -> Account
  def some_local_account
    @some_local_account ||= Account.representative
  end

  # @rbs () -> nil
  def ensure_disabled
    disable! if enabled?
  end
end
