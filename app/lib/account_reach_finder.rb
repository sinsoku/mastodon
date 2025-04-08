# frozen_string_literal: true

class AccountReachFinder
  RECENT_LIMIT = 2_000
  STATUS_LIMIT = 200
  STATUS_SINCE = 2.days

  # @rbs (Account) -> void
  def initialize(account)
    @account = account
  end

  # @rbs () -> Array[untyped]
  def inboxes
    (followers_inboxes + reporters_inboxes + recently_mentioned_inboxes + recently_followed_inboxes + recently_requested_inboxes + relay_inboxes).uniq
  end

  private

  # @rbs () -> Array[untyped]
  def followers_inboxes
    @account.followers.inboxes
  end

  # @rbs () -> Array[untyped]
  def reporters_inboxes
    Account.where(id: @account.targeted_reports.select(:account_id)).inboxes
  end

  # @rbs () -> Array[untyped]
  def recently_mentioned_inboxes
    Account
      .joins(:mentions)
      .where(mentions: { status: recent_statuses })
      .inboxes
      .take(RECENT_LIMIT)
  end

  # @rbs () -> Array[untyped]
  def recently_followed_inboxes
    @account
      .following
      .where(follows: { created_at: recent_date_cutoff... })
      .inboxes
      .take(RECENT_LIMIT)
  end

  # @rbs () -> Array[untyped]
  def recently_requested_inboxes
    Account
      .where(id: @account.follow_requests.where({ created_at: recent_date_cutoff... }).select(:target_account_id))
      .inboxes
      .take(RECENT_LIMIT)
  end

  # @rbs () -> Array[untyped]
  def relay_inboxes
    Relay.enabled.pluck(:inbox_url)
  end

  # @rbs () -> Integer
  def oldest_status_id
    Mastodon::Snowflake
      .id_at(recent_date_cutoff, with_random: false)
  end

  # @rbs () -> ActiveSupport::TimeWithZone
  def recent_date_cutoff
    @account.suspended? && @account.suspension_origin_local? ? @account.suspended_at - STATUS_SINCE : STATUS_SINCE.ago
  end

  # @rbs () -> Status::ActiveRecord_AssociationRelation
  def recent_statuses
    @account
      .statuses
      .recent
      .where(id: oldest_status_id...)
      .limit(STATUS_LIMIT)
  end
end
