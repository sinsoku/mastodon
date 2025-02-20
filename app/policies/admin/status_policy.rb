# frozen_string_literal: true

class Admin::StatusPolicy < ApplicationPolicy
  # @rbs (Account?, Status, ?Hash[untyped, untyped]) -> void
  def initialize(current_account, record, preloaded_relations = {})
    super(current_account, record)

    @preloaded_relations = preloaded_relations
  end

  def index?
    role.can?(:manage_reports, :manage_users)
  end

  # @rbs () -> (void | bool)
  def show?
    role.can?(:manage_reports, :manage_users) && (record.public_visibility? || record.unlisted_visibility? || record.reported? || viewable_through_normal_policy?)
  end

  # @rbs () -> bool
  def destroy?
    role.can?(:manage_reports)
  end

  # @rbs () -> bool
  def update?
    role.can?(:manage_reports)
  end

  def review?
    role.can?(:manage_taxonomies)
  end

  private

  def viewable_through_normal_policy?
    StatusPolicy.new(current_account, record, @preloaded_relations).show?
  end
end
