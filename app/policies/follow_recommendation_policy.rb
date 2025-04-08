# frozen_string_literal: true

class FollowRecommendationPolicy < ApplicationPolicy
  # @rbs () -> bool
  def show?
    role.can?(:manage_taxonomies)
  end

  # @rbs () -> bool
  def suppress?
    role.can?(:manage_taxonomies)
  end

  # @rbs () -> bool
  def unsuppress?
    role.can?(:manage_taxonomies)
  end
end
