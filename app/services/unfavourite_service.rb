# frozen_string_literal: true

class UnfavouriteService < BaseService
  include Payloadable

  # @rbs (Account, Status) -> Favourite
  def call(account, status)
    favourite = Favourite.find_by!(account: account, status: status)
    favourite.destroy!
    create_notification(favourite) if !status.account.local? && status.account.activitypub?
    favourite
  end

  private

  # @rbs (Favourite) -> String
  def create_notification(favourite)
    status = favourite.status
    ActivityPub::DeliveryWorker.perform_async(build_json(favourite), favourite.account_id, status.account.inbox_url)
  end

  # @rbs (Favourite) -> String
  def build_json(favourite)
    Oj.dump(serialize_payload(favourite, ActivityPub::UndoLikeSerializer))
  end
end
