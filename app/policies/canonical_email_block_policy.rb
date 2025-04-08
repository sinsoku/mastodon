# frozen_string_literal: true

class CanonicalEmailBlockPolicy < ApplicationPolicy
  # @rbs () -> bool
  def index?
    role.can?(:manage_blocks)
  end

  # @rbs () -> bool
  def show?
    role.can?(:manage_blocks)
  end

  # @rbs () -> bool
  def test?
    role.can?(:manage_blocks)
  end

  # @rbs () -> bool
  def create?
    role.can?(:manage_blocks)
  end

  # @rbs () -> bool
  def destroy?
    role.can?(:manage_blocks)
  end
end
