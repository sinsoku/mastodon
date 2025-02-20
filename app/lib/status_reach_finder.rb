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

  # @rbs () -> (Array[untyped] | void)
  def inboxes
    (reached_account_inboxes + followers_inboxes + relay_inboxes).uniq
  end

  private

  # @rbs () -> Array[untyped]
  def reached_account_inboxes
    scope = Account.where(id: reached_account_ids)
    inboxes_without_suspended_for(scope)
  end

  # @rbs () -> void
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

  # @rbs () -> void
  def replied_to_account_id
    @status.in_reply_to_account_id if distributable?
  end

  # @rbs () -> void
  def reblog_of_account_id
    @status.reblog.account_id if @status.reblog?
  end

  # @rbs () -> void
  def mentioned_account_ids
    @status.mentions.pluck(:account_id)
  end

  # Beware: Reblogs can be created without the author having had access to the status
  # @rbs () -> void
  def reblogs_account_ids
    @status.reblogs.rewhere(deleted_at: [nil, @status.deleted_at]).pluck(:account_id) if distributable? || unsafe?
  end

  # Beware: Favourites can be created without the author having had access to the status
  # @rbs () -> void
  def favourites_account_ids
    @status.favourites.pluck(:account_id) if distributable? || unsafe?
  end

  # Beware: Replies can be created without the author having had access to the status
  # @rbs () -> void
  def replies_account_ids
    @status.replies.pluck(:account_id) if distributable? || unsafe?
  end

  # @rbs () -> void
  def followers_inboxes
    scope = followers_scope
    inboxes_without_suspended_for(scope)
  end

  # @rbs () -> void
  def relay_inboxes
    if @status.public_visibility?
      Relay.enabled.pluck(:inbox_url)
    else
      []
    end
  end

  # @rbs () -> void
  def distributable?
    @status.public_visibility? || @status.unlisted_visibility?
  end

  # @rbs () -> void
  def unsafe?
    @options[:unsafe]
  end

  # @rbs () -> (ActiveRecord::Associations::CollectionProxy | ActiveRecord::Relation)
  def followers_scope
    if @status.in_reply_to_local_account? && distributable?
      @status.account.followers.or(@status.thread.account.followers.not_domain_blocked_by_account(@status.account))
    elsif @status.direct_visibility? || @status.limited_visibility?
      Account.none
    else
      @status.account.followers
    end
  end

  # @rbs (ActiveRecord::Relation | ActiveRecord::Associations::CollectionProxy) -> void
  def inboxes_without_suspended_for(scope)
    scope.merge!(Account.without_suspended) unless unsafe?
    scope.inboxes
  end
end
