# frozen_string_literal: true

class RelationshipFilter
  KEYS = %i(
    relationship
    status
    by_domain
    activity
    order
    location
  ).freeze

  IGNORED_PARAMS = %w(relationship page).freeze

  attr_reader :params, :account

  # @rbs (Account, Hash[untyped, untyped] | ActionController::Parameters) -> void
  def initialize(account, params)
    @account = account
    @params  = params

    set_defaults!
  end

  # @rbs () -> Account::ActiveRecord_AssociationRelation
  def results
    scope = scope_for('relationship', params['relationship'].to_s.strip)

    params.each do |key, value|
      next if IGNORED_PARAMS.include?(key)

      scope.merge!(scope_for(key.to_s, value.to_s.strip)) if value.present?
    end

    scope
  end

  private

  # @rbs () -> String?
  def set_defaults!
    params['relationship'] = 'following' if params['relationship'].blank?
    params['order']        = 'recent' if params['order'].blank?
  end

  # @rbs (String, String) -> (Account::ActiveRecord_AssociationRelation | Account::ActiveRecord_Relation | Follow::ActiveRecord_Relation)
  def scope_for(key, value)
    case key
    when 'relationship'
      relationship_scope(value)
    when 'by_domain'
      by_domain_scope(value)
    when 'location'
      location_scope(value)
    when 'status'
      status_scope(value)
    when 'order'
      order_scope(value)
    when 'activity'
      activity_scope(value)
    else
      raise Mastodon::InvalidParameterError, "Unknown filter: #{key}"
    end
  end

  # @rbs (String) -> Account::ActiveRecord_AssociationRelation
  def relationship_scope(value)
    case value
    when 'following'
      account.following.includes(:account_stat).reorder(nil)
    when 'followed_by'
      account.followers.includes(:account_stat).reorder(nil)
    when 'mutual'
      account.followers.includes(:account_stat).reorder(nil).merge(Account.where(id: account.following))
    when 'invited'
      Account.joins(user: :invite).merge(Invite.where(user: account.user)).includes(:account_stat).reorder(nil)
    else
      raise Mastodon::InvalidParameterError, "Unknown relationship: #{value}"
    end
  end

  def by_domain_scope(value)
    Account.where(domain: value)
  end

  def location_scope(value)
    case value
    when 'local'
      Account.local
    when 'remote'
      Account.remote
    else
      raise Mastodon::InvalidParameterError, "Unknown location: #{value}"
    end
  end

  def status_scope(value)
    case value
    when 'moved'
      Account.where.not(moved_to_account_id: nil)
    when 'primary'
      Account.where(moved_to_account_id: nil)
    else
      raise Mastodon::InvalidParameterError, "Unknown status: #{value}"
    end
  end

  # @rbs (String) -> (Account::ActiveRecord_Relation | Follow::ActiveRecord_Relation)
  def order_scope(value)
    case value
    when 'active'
      Account.by_recent_status
    when 'recent'
      params[:relationship] == 'invited' ? Account.recent : Follow.recent
    else
      raise Mastodon::InvalidParameterError, "Unknown order: #{value}"
    end
  end

  # @rbs (String) -> Account::ActiveRecord_Relation
  def activity_scope(value)
    case value
    when 'dormant'
      Account.dormant
    else
      raise Mastodon::InvalidParameterError, "Unknown activity: #{value}"
    end
  end
end
