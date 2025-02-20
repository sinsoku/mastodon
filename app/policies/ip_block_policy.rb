# frozen_string_literal: true

class IpBlockPolicy < ApplicationPolicy
  # @rbs () -> bool
  def index?
    role.can?(:manage_blocks)
  end

  # @rbs () -> bool
  def show?
    role.can?(:manage_blocks)
  end

  # @rbs () -> bool
  def create?
    role.can?(:manage_blocks)
  end

  # @rbs () -> bool
  def update?
    role.can?(:manage_blocks)
  end

  # @rbs () -> bool
  def destroy?
    role.can?(:manage_blocks)
  end
end
