# frozen_string_literal: true

module BrowserDetection
  extend ActiveSupport::Concern

  included do
    before_save :assign_user_agent
  end

  # @rbs () -> (Browser::Chrome | Browser::Unknown | Browser::Opera)
  def detection
    @detection ||= Browser.new(user_agent)
  end

  # @rbs () -> (Integer | Symbol)
  def browser
    detection.id
  end

  # @rbs () -> (Integer | Symbol)
  def platform
    detection.platform.id
  end

  private

  # @rbs () -> String
  def assign_user_agent
    self.user_agent ||= ''
  end
end
