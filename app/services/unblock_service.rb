# frozen_string_literal: true

class UnblockService < BaseService
  include Payloadable

  # @rbs (Account, Account) -> void
  def call(account, target_account)
    return unless account.blocking?(target_account)

    unblock = account.unblock!(target_account)
    create_notification(unblock) if !target_account.local? && target_account.activitypub?
    unblock
  end

  private

  # @rbs (Block) -> void
  def create_notification(unblock)
    ActivityPub::DeliveryWorker.perform_async(build_json(unblock), unblock.account_id, unblock.target_account.inbox_url)
  end

  # @rbs (Block) -> void
  def build_json(unblock)
    Oj.dump(serialize_payload(unblock, ActivityPub::UndoBlockSerializer))
  end
end
