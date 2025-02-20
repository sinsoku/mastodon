# frozen_string_literal: true

class WebfingerResource
  attr_reader :resource

  class InvalidRequest < StandardError; end

  # @rbs (String) -> void
  def initialize(resource)
    @resource = resource
  end

  # @rbs () -> (String | void)?
  def username
    case resource
    when %r{\A(https?://)?#{instance_actor_regexp}/?\Z}
      Rails.configuration.x.local_domain
    when /\Ahttps?/i
      username_from_url
    when /@/
      username_from_acct
    else
      raise InvalidRequest
    end
  end

  private

  # @rbs () -> Regexp
  def instance_actor_regexp
    hosts = [Rails.configuration.x.local_domain, Rails.configuration.x.web_domain]
    hosts.concat(Rails.configuration.x.alternate_domains) if Rails.configuration.x.alternate_domains.present?

    Regexp.union(hosts)
  end

  # @rbs () -> void
  def username_from_url
    if account_show_page?
      path_params[:username]
    elsif instance_actor_page?
      Rails.configuration.x.local_domain
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  # @rbs () -> void
  def instance_actor_page?
    path_params[:controller] == 'instance_actors'
  end

  # @rbs () -> void
  def account_show_page?
    path_params[:controller] == 'accounts' && path_params[:action] == 'show'
  end

  # @rbs () -> Hash[untyped, untyped]
  def path_params
    Rails.application.routes.recognize_path(resource)
  end

  # @rbs () -> void
  def username_from_acct
    if domain_matches_local?
      local_username
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  # @rbs () -> Array[untyped]
  def split_acct
    resource_without_acct_string.split('@')
  end

  # @rbs () -> String
  def resource_without_acct_string
    resource.delete_prefix('acct:')
  end

  # @rbs () -> void
  def local_username
    split_acct.first
  end

  # @rbs () -> void
  def local_domain
    split_acct.last
  end

  # @rbs () -> void
  def domain_matches_local?
    TagManager.instance.local_domain?(local_domain) || TagManager.instance.web_domain?(local_domain)
  end
end
