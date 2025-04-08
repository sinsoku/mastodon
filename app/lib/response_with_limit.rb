# frozen_string_literal: true

class ResponseWithLimit
  # @rbs (HTTP::Response?, Integer) -> void
  def initialize(response, limit)
    @response = response
    @limit = limit
  end

  attr_reader :response, :limit
end
