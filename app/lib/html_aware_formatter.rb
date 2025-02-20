# frozen_string_literal: true

class HtmlAwareFormatter
  attr_reader :text, :local, :options

  alias local? local

  # @param [String] text
  # @param [Boolean] local
  # @param [Hash] options
  # @rbs (String, bool, ?Hash[untyped, untyped]) -> void
  def initialize(text, local, options = {})
    @text    = text
    @local   = local
    @options = options
  end

  # @rbs () -> void
  def to_s
    return ''.html_safe if text.blank?

    if local?
      linkify
    else
      reformat.html_safe # rubocop:disable Rails/OutputSafety
    end
  rescue ArgumentError
    ''.html_safe
  end

  private

  # @rbs () -> String
  def reformat
    Sanitize.fragment(text, Sanitize::Config::MASTODON_STRICT)
  end

  # @rbs () -> void
  def linkify
    TextFormatter.new(text, options).to_s
  end
end
