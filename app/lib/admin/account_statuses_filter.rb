# frozen_string_literal: true

class Admin::AccountStatusesFilter < AccountStatusesFilter
  private

  # @rbs () -> void
  def blocked?
    false
  end
end
