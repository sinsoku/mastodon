# frozen_string_literal: true

module PreloadingConcern
  extend ActiveSupport::Concern

  # @rbs (Status::ActiveRecord_Relation | Trends::Statuses::Query | Status::ActiveRecord_Associations_CollectionProxy | Array[untyped] | Status::ActiveRecord_AssociationRelation, Class) -> Array[untyped]
  def preload_collection(scope, klass)
    return scope unless klass.respond_to?(:preload_cacheable_associations)

    scope.to_a.tap do |records|
      klass.preload_cacheable_associations(records)
    end
  end

  # @rbs (Status::ActiveRecord_AssociationRelation | Status::ActiveRecord_Relation, Class, Integer, ActionController::Parameters) -> Array[untyped]
  def preload_collection_paginated_by_id(scope, klass, limit, options)
    preload_collection scope.to_a_paginated_by_id(limit, options), klass
  end
end
