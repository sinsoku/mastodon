# frozen_string_literal: true

class SettingsPolicy < ApplicationPolicy
  # @rbs () -> bool
  def update?
    role.can?(:manage_settings)
  end

  # @rbs () -> bool
  def show?
    role.can?(:manage_settings)
  end

  # @rbs () -> bool
  def destroy?
    role.can?(:manage_settings)
  end
end
