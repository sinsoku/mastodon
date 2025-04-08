# frozen_string_literal: true

class StatusReachFinder
  # @param [Status] status
  # @param [Hash] options
  # @option options [Boolean] :unsafe
  # @rbs (Status, ?Hash[untyped, untyped]) -> void
  def initialize(status, options = {})
    @status  = status
    @options = options
  end

  # @rbs () -> Array[untyped]
  def inboxes
    (reached_account_inboxes + followers_inboxes + relay_inboxes).uniq
  end

  private

  # @rbs () -> Array[untyped]
  def reached_account_inboxes
    Account.where(id: reached_account_ids).inboxes
  end

  # @rbs () -> Array[untyped]
  def reached_account_ids
    # When the status is a reblog, there are no interactions with it
    # directly, we assume all interactions are with the original one

    if @status.reblog?
      [reblog_of_account_id]
    else
      [
        replied_to_account_id,
        reblog_of_account_id,
        mentioned_account_ids,
        reblogs_account_ids,
        favourites_account_ids,
        replies_account_ids,
      ].tap do |arr|
        arr.flatten!
        arr.compact!
        arr.uniq!
      end
    end
  end

  # @rbs () -> Integer?
  def replied_to_account_id
    @status.in_reply_to_account_id if distributable?
  end

  # @rbs () -> Integer?
  def reblog_of_account_id
    @status.reblog.account_id if @status.reblog?
  end

  # @rbs () -> Array[untyped]
  def mentioned_account_ids
    @status.mentions.pluck(:account_id)
  end

  # Beware: Reblogs can be created without the author having had access to the status
  # @rbs () -> Array[untyped]?
  def reblogs_account_ids
    @status.reblogs.rewhere(deleted_at: [nil, @status.deleted_at]).pluck(:account_id) if distributable? || unsafe?
  end

  # Beware: Favourites can be created without the author having had access to the status
  # @rbs () -> Array[untyped]?
  def favourites_account_ids
    @status.favourites.pluck(:account_id) if distributable? || unsafe?
  end

  # Beware: Replies can be created without the author having had access to the status
  # @rbs () -> Array[untyped]?
  def replies_account_ids
    @status.replies.pluck(:account_id) if distributable? || unsafe?
  end

  # @rbs () -> Array[untyped]
  def followers_inboxes
    if @status.in_reply_to_local_account? && distributable?
      @status.account.followers.or(@status.thread.account.followers.not_domain_blocked_by_account(@status.account)).inboxes
    elsif @status.direct_visibility? || @status.limited_visibility?
      []
    else
      @status.account.followers.inboxes
    end
  end

  # @rbs () -> Array[untyped]
  def relay_inboxes
    if @status.public_visibility?
      Relay.enabled.pluck(:inbox_url)
    else
      []
    end
  end

  # @rbs () -> bool
  def distributable?
    @status.public_visibility? || @status.unlisted_visibility?
  end

  # @rbs () -> nil
  def unsafe?
    @options[:unsafe]
  end
end
