# frozen_string_literal: true

module DatabaseHelper
  # @rbs () -> void
  def replica_enabled?
    ENV['REPLICA_DB_NAME'] || ENV.fetch('REPLICA_DATABASE_URL', nil)
  end
  module_function :replica_enabled?

  # @rbs () -> (void | DomainBlockPreviewPresenter)?
  def with_read_replica(&block)
    if replica_enabled?
      ApplicationRecord.connected_to(role: :reading, prevent_writes: true, &block)
    else
      yield
    end
  end

  # @rbs () -> void
  def with_primary(&block)
    if replica_enabled?
      ApplicationRecord.connected_to(role: :writing, &block)
    else
      yield
    end
  end
end
