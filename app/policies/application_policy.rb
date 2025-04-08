# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :current_account, :record

  # @rbs (Account?, (Class | Symbol | IpBlock | Status | User | Account | Webhook | AccountWarning | Poll | AccountModerationNote | Rule | DomainAllow | AccountWarningPreset | DomainBlock | Invite | CanonicalEmailBlock | Report | ReportNote | CustomEmoji | Appeal | Module | Tag | UserRole | EmailDomainBlock | Announcement)?) -> void
  def initialize(current_account, record)
    @current_account = current_account
    @record          = record
  end

  private

  # @rbs () -> User?
  def current_user
    current_account&.user
  end

  # @rbs () -> bool
  def user_signed_in?
    !current_user.nil?
  end

  # @rbs () -> UserRole
  def role
    current_user&.role || UserRole.nobody
  end
end
