# frozen_string_literal: true

class StatusFilter
  attr_reader :status, :account

  # @rbs (Status, Account?, ?Hash[untyped, untyped]) -> void
  def initialize(status, account, preloaded_relations = {})
    @status              = status
    @account             = account
    @preloaded_relations = preloaded_relations
  end

  # @rbs () -> (bool | Hash[untyped, untyped])
  def filtered?
    return false if !account.nil? && account.id == status.account_id

    blocked_by_policy? || (account_present? && filtered_status?) || silenced_account?
  end

  private

  # @rbs () -> bool
  def account_present?
    !account.nil?
  end

  # @rbs () -> (bool | Hash[untyped, untyped])?
  def filtered_status?
    blocking_account? || blocking_domain? || muting_account?
  end

  # @rbs () -> bool?
  def blocking_account?
    @preloaded_relations[:blocking] ? @preloaded_relations[:blocking][status.account_id] : account.blocking?(status.account_id)
  end

  # @rbs () -> bool?
  def blocking_domain?
    @preloaded_relations[:domain_blocking_by_domain] ? @preloaded_relations[:domain_blocking_by_domain][status.account_domain] : account.domain_blocking?(status.account_domain)
  end

  # @rbs () -> (Hash[untyped, untyped] | bool)?
  def muting_account?
    @preloaded_relations[:muting] ? @preloaded_relations[:muting][status.account_id] : account.muting?(status.account_id)
  end

  # @rbs () -> bool
  def silenced_account?
    !account&.silenced? && status_account_silenced? && !account_following_status_account?
  end

  # @rbs () -> bool
  def status_account_silenced?
    status.account.silenced?
  end

  # @rbs () -> bool?
  def account_following_status_account?
    @preloaded_relations[:following] ? @preloaded_relations[:following][status.account_id] : account&.following?(status.account_id)
  end

  # @rbs () -> bool
  def blocked_by_policy?
    !policy_allows_show?
  end

  # @rbs () -> bool
  def policy_allows_show?
    StatusPolicy.new(account, status, @preloaded_relations).show?
  end
end
