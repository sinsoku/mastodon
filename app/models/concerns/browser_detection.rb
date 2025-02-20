# frozen_string_literal: true

module BrowserDetection
  extend ActiveSupport::Concern

  included do
    before_save :assign_user_agent
  end

  # @rbs () -> (Browser::Unknown | Browser::Safari | void)
  def detection
    @detection ||= Browser.new(user_agent)
  end

  # @rbs () -> (Symbol | void)
  def browser
    detection.id
  end

  # @rbs () -> (Symbol | void)
  def platform
    detection.platform.id
  end

  private

  # @rbs () -> String
  def assign_user_agent
    self.user_agent ||= ''
  end
end
