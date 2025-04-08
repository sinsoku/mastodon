# frozen_string_literal: true

class RelayPolicy < ApplicationPolicy
  # @rbs () -> bool
  def update?
    role.can?(:manage_federation)
  end
end
