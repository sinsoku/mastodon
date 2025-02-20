# frozen_string_literal: true

module FormattingHelper
  SYNDICATED_EMOJI_STYLES = <<~CSS.squish
    height: 1.1em;
    margin: -.2ex .15em .2ex;
    object-fit: contain;
    vertical-align: middle;
    width: 1.1em;
  CSS

  # @rbs (String, bool, ?Hash[untyped, untyped]) -> void
  def html_aware_format(text, local, options = {})
    HtmlAwareFormatter.new(text, local, options).to_s
  end

  # @rbs (String, ?Hash[untyped, untyped]) -> void
  def linkify(text, options = {})
    TextFormatter.new(text, options).to_s
  end

  # @rbs (PreviewCard) -> void
  def url_for_preview_card(preview_card)
    preview_card.url
  end

  # @rbs (Status) -> void
  def extract_status_plain_text(status)
    PlainTextFormatter.new(status.text, status.local?).to_s
  end
  module_function :extract_status_plain_text

  # @rbs (Status | StatusEdit) -> void
  def status_content_format(status)
    MastodonOTELTracer.in_span('HtmlAwareFormatter rendering') do |span|
      span.add_attributes(
        'app.formatter.content.type' => 'status',
        'app.formatter.content.origin' => status.local? ? 'local' : 'remote'
      )

      html_aware_format(status.text, status.local?, preloaded_accounts: [status.account] + (status.respond_to?(:active_mentions) ? status.active_mentions.map(&:account) : []))
    end
  end

  # @rbs (Status) -> void
  def rss_status_content_format(status)
    prerender_custom_emojis(
      wrapped_status_content_format(status),
      status.emojis,
      style: SYNDICATED_EMOJI_STYLES
    ).to_str
  end

  # @rbs (Account | REST::AccountSerializer::AccountDecorator) -> void
  def account_bio_format(account)
    MastodonOTELTracer.in_span('HtmlAwareFormatter rendering') do |span|
      span.add_attributes(
        'app.formatter.content.type' => 'account_bio',
        'app.formatter.content.origin' => account.local? ? 'local' : 'remote'
      )

      html_aware_format(account.note, account.local?)
    end
  end

  # @rbs (Account::Field, ?with_rel_me: bool) -> void
  def account_field_value_format(field, with_rel_me: true)
    if field.verified? && !field.account.local?
      TextFormatter.shortened_link(field.value_for_verification)
    else
      html_aware_format(field.value, field.account.local?, with_rel_me: with_rel_me, with_domains: true, multiline: false)
    end
  end

  # @rbs (String) -> void
  def markdown(text)
    Redcarpet::Markdown.new(Redcarpet::Render::HTML, escape_html: true, no_images: true).render(text).html_safe # rubocop:disable Rails/OutputSafety
  end

  private

  # @rbs (Status) -> void
  def wrapped_status_content_format(status)
    safe_join [
      rss_content_preroll(status),
      status_content_format(status),
      rss_content_postroll(status),
    ]
  end

  # @rbs (Status) -> void
  def rss_content_preroll(status)
    if status.spoiler_text?
      safe_join [
        tag.p { spoiler_with_warning(status) },
        tag.hr,
      ]
    end
  end

  # @rbs (Status) -> void
  def spoiler_with_warning(status)
    safe_join [
      tag.strong { I18n.t('rss.content_warning', locale: available_locale_or_nil(status.language) || I18n.default_locale) },
      status.spoiler_text,
    ]
  end

  # @rbs (Status) -> void
  def rss_content_postroll(status)
    if status.preloadable_poll
      tag.p do
        poll_option_tags(status)
      end
    end
  end

  # @rbs (Status) -> void
  def poll_option_tags(status)
    safe_join(
      status.preloadable_poll.options.map do |option|
        tag.send(status.preloadable_poll.multiple? ? 'checkbox' : 'radio', option, disabled: true)
      end,
      tag.br
    )
  end
end
