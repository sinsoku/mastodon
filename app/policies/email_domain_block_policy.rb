# frozen_string_literal: true

class EmailDomainBlockPolicy < ApplicationPolicy
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
  def destroy?
    role.can?(:manage_blocks)
  end
end
