# frozen_string_literal: true

class CacheBuster
  # @rbs (?Hash[untyped, untyped]) -> void
  def initialize(options = {})
    @secret_header = options[:secret_header]
    @secret = options[:secret]
    @http_method = options[:http_method] || 'GET'
  end

  # @rbs (String) -> void
  def bust(url)
    site = Addressable::URI.parse(url).normalized_site

    request_pool.with(site) do |http_client|
      build_request(url, http_client).perform
    end
  end

  private

  # @rbs () -> RequestPool
  def request_pool
    RequestPool.current
  end

  # @rbs (String, HTTP::Client) -> Request
  def build_request(url, http_client)
    request = Request.new(@http_method.downcase.to_sym, url, http_client: http_client)
    request.add_headers(@secret_header => @secret) if @secret_header.present? && @secret && !@secret.empty?

    request
  end
end
