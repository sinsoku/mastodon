# frozen_string_literal: true

class PermalinkRedirector
  include RoutingHelper

  # @rbs (String) -> void
  def initialize(path)
    @path = path
    @object = nil
  end

  # @rbs () -> (Status | Account)?
  def object
    @object ||= begin
      if at_username_status_request? || statuses_status_request?
        status = Status.find_by(id: second_segment)
        status if status&.distributable? && !status&.local?
      elsif at_username_request?
        username, domain = first_segment.delete_prefix('@').split('@')
        domain = nil if TagManager.instance.local_domain?(domain)
        account = Account.find_remote(username, domain)
        account unless account&.local?
      elsif accounts_request? && record_integer_id_request?
        account = Account.find_by(id: second_segment)
        account unless account&.local?
      end
    end
  end

  # @rbs () -> String?
  def redirect_path
    return ActivityPub::TagManager.instance.url_for(object) if object.present?

    @path.delete_prefix('/deck') if @path.start_with?('/deck')
  end

  def redirect_uri
    return ActivityPub::TagManager.instance.uri_for(object) if object.present?

    @path.delete_prefix('/deck') if @path.start_with?('/deck')
  end

  # @rbs () -> String
  def redirect_confirmation_path
    case object.class.name
    when 'Account'
      redirect_account_path(object.id)
    when 'Status'
      redirect_status_path(object.id)
    else
      @path.delete_prefix('/deck') if @path.start_with?('/deck')
    end
  end

  private

  # @rbs () -> (bool | Integer)?
  def at_username_status_request?
    at_username_request? && record_integer_id_request?
  end

  # @rbs () -> (bool | Integer)
  def statuses_status_request?
    statuses_request? && record_integer_id_request?
  end

  # @rbs () -> bool
  def at_username_request?
    first_segment.present? && first_segment.start_with?('@')
  end

  # @rbs () -> bool
  def statuses_request?
    first_segment == 'statuses'
  end

  # @rbs () -> bool
  def accounts_request?
    first_segment == 'accounts'
  end

  # @rbs () -> Integer?
  def record_integer_id_request?
    second_segment =~ /\d/
  end

  # @rbs () -> String?
  def first_segment
    path_segments.first
  end

  # @rbs () -> String?
  def second_segment
    path_segments.second
  end

  # @rbs () -> Array[untyped]
  def path_segments
    @path_segments ||= @path.split('?')[0].delete_prefix('/deck').delete_prefix('/').split('/')
  end
end
