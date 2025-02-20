# frozen_string_literal: true

class DomainResource
  attr_reader :domain

  RESOLVE_TIMEOUT = 5

  # @rbs (String) -> void
  def initialize(domain)
    @domain = domain
  end

  # @rbs () -> (void | Array[untyped])
  def mx
    Resolv::DNS.open do |dns|
      dns.timeouts = RESOLVE_TIMEOUT
      dns
        .getresources(domain, Resolv::DNS::Resource::IN::MX)
        .to_a
        .map { |mx| mx.exchange.to_s }
        .compact_blank
    end
  end
end
