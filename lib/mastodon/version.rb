# frozen_string_literal: true

module Mastodon
  module Version
    module_function

    # @rbs () -> void
    def major
      4
    end

    # @rbs () -> void
    def minor
      4
    end

    # @rbs () -> void
    def patch
      0
    end

    # @rbs () -> void
    def default_prerelease
      'alpha.1'
    end

    # @rbs () -> String
    def prerelease
      ENV['MASTODON_VERSION_PRERELEASE'].presence || default_prerelease
    end

    # @rbs () -> nil
    def build_metadata
      ENV.fetch('MASTODON_VERSION_METADATA', nil)
    end

    # @rbs () -> Array[untyped]
    def to_a
      [major, minor, patch].compact
    end

    # @rbs () -> (void | String)
    def to_s
      components = [to_a.join('.')]
      components << "-#{prerelease}" if prerelease.present?
      components << "+#{build_metadata}" if build_metadata.present?
      components.join
    end

    # @rbs () -> void
    def gem_version
      @gem_version ||= Gem::Version.new(to_s.split('+')[0])
    end

    # @rbs () -> void
    def api_versions
      {
        mastodon: 2,
      }
    end

    # @rbs () -> (void | String)
    def repository
      ENV.fetch('GITHUB_REPOSITORY', 'mastodon/mastodon')
    end

    # @rbs () -> void
    def source_base_url
      ENV.fetch('SOURCE_BASE_URL', "https://github.com/#{repository}")
    end

    # specify git tag or commit hash here
    # @rbs () -> void
    def source_tag
      ENV.fetch('SOURCE_TAG', nil)
    end

    # @rbs () -> void
    def source_url
      if source_tag
        "#{source_base_url}/tree/#{source_tag}"
      else
        source_base_url
      end
    end

    def source_commit
      ENV.fetch('SOURCE_COMMIT', nil)
    end

    # @rbs () -> (void | String)
    def user_agent
      @user_agent ||= "Mastodon/#{Version} (#{HTTP::Request::USER_AGENT}; +http#{Rails.configuration.x.use_https ? 's' : ''}://#{Rails.configuration.x.web_domain}/)"
    end
  end
end
