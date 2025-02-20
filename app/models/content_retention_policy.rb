# frozen_string_literal: true

class ContentRetentionPolicy
  # @rbs () -> void
  def self.current
    new
  end

  # @rbs () -> void
  def media_cache_retention_period
    retention_period Setting.media_cache_retention_period
  end

  # @rbs () -> void
  def content_cache_retention_period
    retention_period Setting.content_cache_retention_period
  end

  # @rbs () -> void
  def backups_retention_period
    retention_period Setting.backups_retention_period
  end

  private

  # @rbs (Integer?) -> void
  def retention_period(value)
    value.days if value.is_a?(Integer) && value.positive?
  end
end
