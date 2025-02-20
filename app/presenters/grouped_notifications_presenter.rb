# frozen_string_literal: true

class GroupedNotificationsPresenter < ActiveModelSerializers::Model
  # @rbs (Array[untyped], ?Hash[untyped, untyped]) -> void
  def initialize(grouped_notifications, options = {})
    super()

    @grouped_notifications = grouped_notifications
    @options = options
  end

  # @rbs () -> Array[untyped]
  def notification_groups
    @grouped_notifications
  end

  # @rbs () -> Array[untyped]
  def statuses
    @grouped_notifications.filter_map(&:target_status).uniq(&:id)
  end

  # @rbs () -> (void | Array[untyped])
  def accounts
    @accounts ||= begin
      if partial_avatars?
        @grouped_notifications.map { |group| group.sample_accounts.first }.uniq(&:id)
      else
        @grouped_notifications.flat_map(&:sample_accounts).uniq(&:id)
      end
    end
  end

  # @rbs () -> Array[untyped]
  def partial_accounts
    @partial_accounts ||= begin
      if partial_avatars?
        @grouped_notifications.flat_map { |group| group.sample_accounts[1...] }.uniq(&:id).filter { |account| accounts.exclude?(account) }
      else
        []
      end
    end
  end

  private

  # @rbs () -> void
  def partial_avatars?
    @options[:expand_accounts] == 'partial_avatars'
  end
end
