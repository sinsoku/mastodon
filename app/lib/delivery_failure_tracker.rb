# frozen_string_literal: true

class DeliveryFailureTracker
  include Redisable

  FAILURE_DAYS_THRESHOLD = 7

  # @rbs (String) -> void
  def initialize(url_or_host)
    @host = url_or_host.start_with?('https://', 'http://') ? Addressable::URI.parse(url_or_host).normalized_host : url_or_host
  end

  # @rbs () -> void
  def track_failure!
    redis.sadd(exhausted_deliveries_key, today)
    UnavailableDomain.create(domain: @host) if reached_failure_threshold?
  end

  # @rbs () -> (void | UnavailableDomain)?
  def track_success!
    redis.del(exhausted_deliveries_key)
    UnavailableDomain.find_by(domain: @host)&.destroy
  end

  def clear_failures!
    redis.del(exhausted_deliveries_key)
  end

  # @rbs () -> Integer
  def days
    redis.scard(exhausted_deliveries_key) || 0
  end

  # @rbs (String) -> (void | bool)
  def available?
    !UnavailableDomain.exists?(domain: @host)
  end

  # @rbs () -> Array[untyped]
  def exhausted_deliveries_days
    @exhausted_deliveries_days ||= redis.smembers(exhausted_deliveries_key).sort.map { |date| Date.new(date.slice(0, 4).to_i, date.slice(4, 2).to_i, date.slice(6, 2).to_i) }
  end

  alias reset! track_success!

  class << self
    include Redisable

    # @rbs (Array[untyped]) -> (void | Array[untyped])
    def without_unavailable(urls)
      unavailable_domains_map = Rails.cache.fetch('unavailable_domains') { UnavailableDomain.pluck(:domain).index_with(true) }

      urls.reject do |url|
        host = Addressable::URI.parse(url).normalized_host
        unavailable_domains_map[host]
      end
    end

    # @rbs (String) -> (void | bool)
    def available?(url)
      new(url).available?
    end

    # @rbs (String) -> void
    def reset!(url)
      new(url).reset!
    end

    def warning_domains
      domains = redis.keys(exhausted_deliveries_key_by('*')).map do |key|
        key.delete_prefix(exhausted_deliveries_key_by(''))
      end

      domains - UnavailableDomain.pluck(:domain)
    end

    # @rbs (?Array[untyped]) -> Hash[untyped, untyped]
    def warning_domains_map(domains = nil)
      if domains.nil?
        warning_domains.index_with { |domain| redis.scard(exhausted_deliveries_key_by(domain)) }
      else
        domains -= UnavailableDomain.where(domain: domains).pluck(:domain)
        domains.index_with { |domain| redis.scard(exhausted_deliveries_key_by(domain)) }.filter { |_, days| days.positive? }
      end
    end

    private

    # @rbs (String) -> void
    def exhausted_deliveries_key_by(host)
      "exhausted_deliveries:#{host}"
    end
  end

  private

  # @rbs () -> void
  def exhausted_deliveries_key
    "exhausted_deliveries:#{@host}"
  end

  # @rbs () -> void
  def today
    Time.now.utc.strftime('%Y%m%d')
  end

  # @rbs () -> void
  def reached_failure_threshold?
    days >= FAILURE_DAYS_THRESHOLD
  end
end
