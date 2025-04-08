# frozen_string_literal: true

module Reviewable
  extend ActiveSupport::Concern

  included do
    scope :reviewed, -> { where.not(reviewed_at: nil) }
    scope :unreviewed, -> { where(reviewed_at: nil) }
  end

  # @rbs () -> bool
  def requires_review?
    reviewed_at.nil?
  end

  # @rbs () -> bool
  def reviewed?
    reviewed_at.present?
  end

  # @rbs () -> bool
  def requested_review?
    requested_review_at.present?
  end

  # @rbs () -> bool
  def requires_review_notification?
    requires_review? && !requested_review?
  end
end
