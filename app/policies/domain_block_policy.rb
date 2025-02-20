# frozen_string_literal: true

class DomainBlockPolicy < ApplicationPolicy
  # @rbs () -> bool
  def index?
    role.can?(:manage_federation)
  end

  # @rbs () -> bool
  def show?
    role.can?(:manage_federation)
  end

  # @rbs () -> bool
  def create?
    role.can?(:manage_federation)
  end

  # @rbs () -> bool
  def update?
    role.can?(:manage_federation)
  end

  # @rbs () -> bool
  def destroy?
    role.can?(:manage_federation)
  end
end
