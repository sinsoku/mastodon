# frozen_string_literal: true

module Xmstdn::SSL
  private

  def onion?
    request.host == ENV['HIDDEN_DOT_ONION']
  end

  # Override ApplicationController#https_enabled?
  def https_enabled?
    Rails.env.production? && !onion?
  end
end
