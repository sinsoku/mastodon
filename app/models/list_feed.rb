# frozen_string_literal: true

class ListFeed < Feed
  # @rbs (List) -> void
  def initialize(list)
    super(:list, list.id)
  end
end
