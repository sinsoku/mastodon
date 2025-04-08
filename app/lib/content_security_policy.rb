# frozen_string_literal: true

class ContentSecurityPolicy
  # @rbs () -> String
  def base_host
    Rails.configuration.x.web_domain
  end

  # @rbs () -> String
  def assets_host
    url_from_configured_asset_host || url_from_base_host
  end

  # @rbs () -> Array[untyped]
  def media_hosts
    [assets_host, cdn_host_value, paperclip_root_url].compact
  end

  # @rbs () -> nil
  def sso_host
    return unless ENV['ONE_CLICK_SSO_LOGIN'] == 'true' && ENV['OMNIAUTH_ONLY'] == 'true' && Devise.omniauth_providers.length == 1

    provider = Devise.omniauth_configs[Devise.omniauth_providers[0]]
    @sso_host ||= begin
      case provider.provider
      when :cas
        provider.cas_url
      when :saml
        provider.options[:idp_sso_target_url]
      when :openid_connect
        provider.options.dig(:client_options, :authorization_endpoint) || OpenIDConnect::Discovery::Provider::Config.discover!(provider.options[:issuer]).authorization_endpoint
      end
    end
  end

  private

  # @rbs () -> String?
  def url_from_configured_asset_host
    Rails.configuration.action_controller.asset_host
  end

  # @rbs () -> String?
  def cdn_host_value
    s3_alias_host || s3_cloudfront_host || azure_alias_host || s3_hostname_host || swift_object_url
  end

  # @rbs () -> String?
  def paperclip_root_url
    root_url = ENV.fetch('PAPERCLIP_ROOT_URL', nil)
    return if root_url.blank?

    (Addressable::URI.parse(assets_host) + root_url).tap do |uri|
      uri.path += '/' unless uri.path.blank? || uri.path.end_with?('/')
    end.to_s
  end

  # @rbs () -> String
  def url_from_base_host
    host_to_url(base_host)
  end

  # @rbs (String?) -> String?
  def host_to_url(host_string)
    uri_from_configuration_and_string(host_string) if host_string.present?
  end

  # @rbs () -> String?
  def s3_alias_host
    host_to_url ENV.fetch('S3_ALIAS_HOST', nil)
  end

  # @rbs () -> String?
  def s3_cloudfront_host
    host_to_url ENV.fetch('S3_CLOUDFRONT_HOST', nil)
  end

  # @rbs () -> String?
  def azure_alias_host
    host_to_url ENV.fetch('AZURE_ALIAS_HOST', nil)
  end

  # @rbs () -> String?
  def s3_hostname_host
    host_to_url ENV.fetch('S3_HOSTNAME', nil)
  end

  # @rbs () -> nil
  def swift_object_url
    url = ENV.fetch('SWIFT_OBJECT_URL', nil)
    return if url.blank? || !url.start_with?('https://')

    url += '/' unless url.end_with?('/')
    url
  end

  # @rbs (String) -> String
  def uri_from_configuration_and_string(host_string)
    Addressable::URI.parse("#{host_protocol}://#{host_string}").tap do |uri|
      uri.path += '/' unless uri.path.blank? || uri.path.end_with?('/')
    end.to_s
  end

  # @rbs () -> String
  def host_protocol
    Rails.configuration.x.use_https ? 'https' : 'http'
  end
end
