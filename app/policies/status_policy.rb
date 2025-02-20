# frozen_string_literal: true

class StatusPolicy < ApplicationPolicy
  # @rbs (Account?, Status, ?Hash[untyped, untyped]) -> void
  def initialize(current_account, record, preloaded_relations = {})
    super(current_account, record)

    @preloaded_relations = preloaded_relations
  end

  # @rbs () -> (void | bool)
  def show?
    return false if author.unavailable?

    if requires_mention?
      owned? || mention_exists?
    elsif private?
      owned? || following_author? || mention_exists?
    else
      current_account.nil? || (!author_blocking? && !author_blocking_domain?)
    end
  end

  # @rbs () -> bool
  def reblog?
    !requires_mention? && (!private? || owned?) && show? && !blocking_author?
  end

  # @rbs () -> bool
  def favourite?
    show? && !blocking_author?
  end

  # @rbs () -> bool
  def destroy?
    owned?
  end

  alias unreblog? destroy?

  # @rbs () -> bool
  def update?
    owned?
  end

  private

  # @rbs () -> (void | bool)
  def requires_mention?
    record.direct_visibility? || record.limited_visibility?
  end

  # @rbs () -> void
  def owned?
    author.id == current_account&.id
  end

  # @rbs () -> (void | bool)
  def private?
    record.private_visibility?
  end

  # @rbs () -> void
  def mention_exists?
    return false if current_account.nil?

    if record.mentions.loaded?
      record.mentions.any? { |mention| mention.account_id == current_account.id }
    else
      record.mentions.exists?(account: current_account)
    end
  end

  # @rbs () -> bool
  def author_blocking_domain?
    return false if current_account.nil? || current_account.domain.nil?

    author.domain_blocking?(current_account.domain)
  end

  # @rbs () -> bool
  def blocking_author?
    return false if current_account.nil?

    @preloaded_relations[:blocking] ? @preloaded_relations[:blocking][author.id] : current_account.blocking?(author)
  end

  # @rbs () -> bool?
  def author_blocking?
    return false if current_account.nil?

    @preloaded_relations[:blocked_by] ? @preloaded_relations[:blocked_by][author.id] : author.blocking?(current_account)
  end

  # @rbs () -> void
  def following_author?
    return false if current_account.nil?

    @preloaded_relations[:following] ? @preloaded_relations[:following][author.id] : current_account.following?(author)
  end

  # @rbs () -> Account
  def author
    record.account
  end
end
