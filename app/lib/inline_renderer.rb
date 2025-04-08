# frozen_string_literal: true

class InlineRenderer
  # @rbs (Status | AnnouncementReaction | Announcement, Account?, Symbol) -> void
  def initialize(object, current_account, template)
    @object          = object
    @current_account = current_account
    @template        = template
  end

  # @rbs (Status | AnnouncementReaction | Announcement, Account?, Symbol) -> Hash[untyped, untyped]
  def render
    case @template
    when :status
      serializer = REST::StatusSerializer
      preload_associations_for_status
    when :notification
      serializer = REST::NotificationSerializer
    when :conversation
      serializer = REST::ConversationSerializer
    when :announcement
      serializer = REST::AnnouncementSerializer
    when :reaction
      serializer = REST::ReactionSerializer
    else
      return
    end

    serializable_resource = ActiveModelSerializers::SerializableResource.new(@object, serializer: serializer, scope: current_user, scope_name: :current_user)
    serializable_resource.as_json
  end

  # @rbs (Status | AnnouncementReaction | Announcement, Account?, Symbol) -> Hash[untyped, untyped]
  def self.render(object, current_account, template)
    new(object, current_account, template).render
  end

  private

  # @rbs () -> Array[untyped]
  def preload_associations_for_status
    ActiveRecord::Associations::Preloader.new(records: [@object], associations: {
      active_mentions: :account,

      reblog: {
        active_mentions: :account,
      },
    }).call
  end

  # @rbs () -> User?
  def current_user
    @current_account&.user
  end
end
