# frozen_string_literal: true

class Admin::AccountStatusesFilter < AccountStatusesFilter
  private

  # @rbs () -> bool
  def blocked?
    false
  end
end
