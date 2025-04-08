# frozen_string_literal: true

module AccountableConcern
  extend ActiveSupport::Concern

  # @rbs (Symbol, IpBlock | CustomEmoji | User | Account | DomainAllow | DomainBlock | EmailDomainBlock | CanonicalEmailBlock | Report | Status | UserRole | UnavailableDomain | Instance | Announcement | Appeal) -> Admin::ActionLog
  def log_action(action, target)
    Admin::ActionLog.create(
      account: current_account,
      action: action,
      target: target
    )
  end
end
