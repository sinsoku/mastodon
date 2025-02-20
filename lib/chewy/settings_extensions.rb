# frozen_string_literal: true

module Chewy
  module SettingsExtensions
    # @rbs () -> void
    def enabled?
      settings[:enabled]
    end
  end
end

Chewy.extend(Chewy::SettingsExtensions)
