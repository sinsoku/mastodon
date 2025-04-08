# frozen_string_literal: true

module Authorization
  extend ActiveSupport::Concern

  include Pundit::Authorization

  # @rbs () -> Account?
  def pundit_user
    current_account
  end

  # @rbs (*untyped) -> (Status | Symbol | User | Account | AccountWarning | Rule | DomainAllow | AccountWarningPreset | Webhook | DomainBlock | Invite | CanonicalEmailBlock | Report | CustomEmoji | ReportNote | Tag | UserRole | EmailDomainBlock | Appeal)?
  def authorize(*)
    super
  rescue Pundit::NotAuthorizedError
    raise Mastodon::NotPermittedError
  end

  # @rbs (Account, Poll | Status, Symbol) -> Status?
  def authorize_with(user, record, query)
    Pundit.authorize(user, record, query)
  rescue Pundit::NotAuthorizedError
    raise Mastodon::NotPermittedError
  end
end
