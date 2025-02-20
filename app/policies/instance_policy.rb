# frozen_string_literal: true

class InstancePolicy < ApplicationPolicy
  # @rbs () -> bool
  def index?
    role.can?(:manage_federation)
  end

  # @rbs () -> bool
  def show?
    role.can?(:manage_federation)
  end

  # @rbs () -> bool
  def destroy?
    role.can?(:manage_federation)
  end
end
