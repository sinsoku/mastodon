# frozen_string_literal: true

class WebhookPolicy < ApplicationPolicy
  # @rbs () -> bool
  def index?
    role.can?(:manage_webhooks)
  end

  # @rbs () -> bool
  def create?
    role.can?(:manage_webhooks)
  end

  # @rbs () -> bool
  def show?
    role.can?(:manage_webhooks)
  end

  # @rbs () -> bool
  def update?
    role.can?(:manage_webhooks) && record.required_permissions.all? { |permission| role.can?(permission) }
  end

  # @rbs () -> bool
  def enable?
    role.can?(:manage_webhooks)
  end

  # @rbs () -> bool
  def disable?
    role.can?(:manage_webhooks)
  end

  # @rbs () -> bool
  def rotate_secret?
    role.can?(:manage_webhooks)
  end

  # @rbs () -> bool
  def destroy?
    role.can?(:manage_webhooks) && record.required_permissions.all? { |permission| role.can?(permission) }
  end
end
