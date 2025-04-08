# frozen_string_literal: true

class DismissNotificationRequestService < BaseService
  # @rbs (NotificationRequest) -> NotificationRequest
  def call(request)
    FilteredNotificationCleanupWorker.perform_async(request.account_id, request.from_account_id)
    request.destroy!
  end
end
