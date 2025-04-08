# frozen_string_literal: true

class RulePolicy < ApplicationPolicy
  # @rbs () -> bool
  def index?
    role.can?(:manage_rules)
  end

  # @rbs () -> bool
  def create?
    role.can?(:manage_rules)
  end

  # @rbs () -> bool
  def update?
    role.can?(:manage_rules)
  end

  # @rbs () -> bool
  def destroy?
    role.can?(:manage_rules)
  end
end
