# frozen_string_literal: true

class HealthController < ActionController::Base # rubocop:disable Rails/ApplicationController
  # @rbs () -> String
  def show
    render plain: 'OK'
  end
end
