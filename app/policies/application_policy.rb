# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :current_account, :record

  # @rbs (Account?, (Class | Poll | Status | User | Symbol | Module | Account | Appeal | TermsOfService | Webhook | CanonicalEmailBlock | EmailDomainBlock | Report | ReportNote | DomainAllow | CustomEmoji | DomainBlock | AccountWarning | AccountModerationNote | Invite | Tag | UserRole | Announcement | IpBlock | Rule | AccountWarningPreset)?) -> void
  def initialize(current_account, record)
    @current_account = current_account
    @record          = record
  end

  private

  # @rbs () -> User?
  def current_user
    current_account&.user
  end

  # @rbs () -> void
  def user_signed_in?
    !current_user.nil?
  end

  # @rbs () -> UserRole
  def role
    current_user&.role || UserRole.nobody
  end
end
