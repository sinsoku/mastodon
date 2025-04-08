# frozen_string_literal: true

class ContentRetentionPolicy
  # @rbs () -> ContentRetentionPolicy
  def self.current
    new
  end

  # @rbs () -> nil
  def media_cache_retention_period
    retention_period Setting.media_cache_retention_period
  end

  # @rbs () -> nil
  def content_cache_retention_period
    retention_period Setting.content_cache_retention_period
  end

  # @rbs () -> ActiveSupport::Duration
  def backups_retention_period
    retention_period Setting.backups_retention_period
  end

  private

  # @rbs (Integer?) -> ActiveSupport::Duration?
  def retention_period(value)
    value.days if value.is_a?(Integer) && value.positive?
  end
end
