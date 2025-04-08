# frozen_string_literal: true

module Cacheable
  extend ActiveSupport::Concern

  module ClassMethods
    @cache_associated = []

    # @rbs (*Symbol | Hash[untyped, untyped]) -> void
    def cache_associated(*associations)
      @cache_associated = associations
    end

    # @rbs () -> (Status::ActiveRecord_Relation | Status::ActiveRecord_AssociationRelation)
    def with_includes
      includes(@cache_associated)
    end

    # @rbs (Array[untyped]) -> Array[untyped]
    def preload_cacheable_associations(records)
      ActiveRecord::Associations::Preloader.new(records: records, associations: @cache_associated).call
    end

    def cache_ids
      select(:id, :updated_at)
    end
  end
end
