# frozen_string_literal: true

class HomeFeed < Feed
  # @rbs (Account) -> void
  def initialize(account)
    @account = account
    super(:home, account.id)
  end

  # @rbs () -> bool
  def regenerating?
    redis.exists?("account:#{@account.id}:regeneration")
  end
end
