# frozen_string_literal: true

class RemoveFromFollowersService < BaseService
  include Payloadable

  # @rbs (Account, Account) -> void
  def call(source_account, target_accounts)
    source_account.passive_relationships.where(account_id: target_accounts).find_each do |follow|
      follow.destroy

      create_notification(follow) if source_account.local? && !follow.account.local? && follow.account.activitypub?
    end
  end

  private

  # @rbs (Follow) -> void
  def create_notification(follow)
    ActivityPub::DeliveryWorker.perform_async(build_json(follow), follow.target_account_id, follow.account.inbox_url)
  end

  # @rbs (Follow) -> void
  def build_json(follow)
    Oj.dump(serialize_payload(follow, ActivityPub::RejectFollowSerializer))
  end
end
