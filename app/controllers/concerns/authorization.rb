# frozen_string_literal: true

module Authorization
  extend ActiveSupport::Concern

  include Pundit::Authorization

  # @rbs () -> void
  def pundit_user
    current_account
  end

  # @rbs (*untyped) -> void
  def authorize(*)
    super
  rescue Pundit::NotAuthorizedError
    raise Mastodon::NotPermittedError
  end

  # @rbs (Account, Poll | Status, Symbol) -> void
  def authorize_with(user, record, query)
    Pundit.authorize(user, record, query)
  rescue Pundit::NotAuthorizedError
    raise Mastodon::NotPermittedError
  end
end
