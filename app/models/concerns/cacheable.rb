# frozen_string_literal: true

module Cacheable
  extend ActiveSupport::Concern

  module ClassMethods
    @cache_associated = []

    # @rbs (*Symbol | Hash[untyped, untyped]) -> void
    def cache_associated(*associations)
      @cache_associated = associations
    end

    # @rbs () -> (ActiveRecord::Relation | ActiveRecord::AssociationRelation)
    def with_includes
      includes(@cache_associated)
    end

    # @rbs (Array[untyped]) -> void
    def preload_cacheable_associations(records)
      ActiveRecord::Associations::Preloader.new(records: records, associations: @cache_associated).call
    end

    def cache_ids
      select(:id, :updated_at)
    end
  end
end
