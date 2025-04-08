# frozen_string_literal: true

class FollowLimitValidator < ActiveModel::Validator
  LIMIT = ENV.fetch('MAX_FOLLOWS_THRESHOLD', 7_500).to_i
  RATIO = ENV.fetch('MAX_FOLLOWS_RATIO', 1.1).to_f

  # @rbs (FollowRequest | Follow) -> ActiveModel::Error?
  def validate(follow)
    return if follow.account.nil? || !follow.account.local?

    follow.errors.add(:base, I18n.t('users.follow_limit_reached', limit: self.class.limit_for_account(follow.account))) if limit_reached?(follow.account)
  end

  class << self
    # @rbs (Account) -> Integer
    def limit_for_account(account)
      if account.following_count < LIMIT
        LIMIT
      else
        [(account.followers_count * RATIO).round, LIMIT].max
      end
    end
  end

  private

  # @rbs (Account) -> bool
  def limit_reached?(account)
    account.following_count >= self.class.limit_for_account(account)
  end
end
