# frozen_string_literal: true

class DeliveryPolicy < ApplicationPolicy
  # @rbs () -> bool
  def clear_delivery_errors?
    role.can?(:manage_federation)
  end

  # @rbs () -> bool
  def restart_delivery?
    role.can?(:manage_federation)
  end

  # @rbs () -> bool
  def stop_delivery?
    role.can?(:manage_federation)
  end
end
