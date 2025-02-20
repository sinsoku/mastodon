# frozen_string_literal: true

class PreviewCardProviderPolicy < ApplicationPolicy
  # @rbs () -> bool
  def index?
    role.can?(:manage_taxonomies)
  end

  # @rbs () -> bool
  def review?
    role.can?(:manage_taxonomies)
  end
end
