# frozen_string_literal: true

module AccountableConcern
  extend ActiveSupport::Concern

  # @rbs (Symbol, User | IpBlock | Relay | Account | Appeal | TermsOfService | CanonicalEmailBlock | EmailDomainBlock | Report | DomainAllow | UnavailableDomain | Instance | CustomEmoji | DomainBlock | Status | Announcement | UserRole) -> void
  def log_action(action, target)
    Admin::ActionLog.create(
      account: current_account,
      action: action,
      target: target
    )
  end
end
