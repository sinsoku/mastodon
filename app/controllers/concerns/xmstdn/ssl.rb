# frozen_string_literal: true

module Xmstdn::SSL
  extend ActiveSupport::Concern

  included do
    force_ssl if: -> { Rails.env.production? && !onion? }
  end

  private

  def onion?
    request.host == ENV['HIDDEN_DOT_ONION']
  end
end
