# frozen_string_literal: true

class TermsOfServicePolicy < ApplicationPolicy
  # @rbs () -> bool
  def index?
    role.can?(:manage_settings)
  end

  # @rbs () -> bool
  def create?
    role.can?(:manage_settings)
  end

  # @rbs () -> bool
  def distribute?
    record.published? && !record.notification_sent? && role.can?(:manage_settings)
  end

  # @rbs () -> bool
  def update?
    !record.published? && role.can?(:manage_settings)
  end

  # @rbs () -> bool
  def destroy?
    !record.published? && role.can?(:manage_settings)
  end
end
