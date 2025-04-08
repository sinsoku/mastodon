# frozen_string_literal: true

# == Schema Information
#
# Table name: software_updates
#
#  id            :bigint(8)        not null, primary key
#  version       :string           not null
#  urgent        :boolean          default(FALSE), not null
#  type          :integer          default("patch"), not null
#  release_notes :string           default(""), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class SoftwareUpdate < ApplicationRecord
  self.inheritance_column = nil

  enum :type, { patch: 0, minor: 1, major: 2 }, suffix: :type

  # @rbs () -> Gem::Version
  def gem_version
    Gem::Version.new(version)
  end

  class << self
    # @rbs () -> bool
    def check_enabled?
      ENV['UPDATE_CHECK_URL'] != ''
    end

    # @rbs () -> Array[untyped]
    def pending_to_a
      return [] unless check_enabled?

      all.to_a.filter { |update| update.gem_version > Mastodon::Version.gem_version }
    end

    # @rbs () -> bool
    def urgent_pending?
      pending_to_a.any?(&:urgent?)
    end
  end
end
