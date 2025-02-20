# frozen_string_literal: true

class LinkDetailsExtractor
  include ActionView::Helpers::TagHelper
  include LanguagesHelper

  # Some publications wrap their JSON-LD data in their <script> tags
  # in commented-out CDATA blocks, they need to be removed before
  # attempting to parse JSON
  CDATA_JUNK_PATTERN = %r{^\s*(
    (/\*\s*<!\[CDATA\[\s*\*/) # Block comment style opening
    |
    (//\s*<!\[CDATA\[) # Single-line comment style opening
    |
    (/\*\s*\]\]>\s*\*/) # Block comment style closing
    |
    (//\s*\]\]>) # Single-line comment style closing
  )\s*$}x

  class StructuredData
    SUPPORTED_TYPES = %w(
      NewsArticle
      WebPage
    ).freeze

    # @rbs (String) -> void
    def initialize(data)
      @data = data
    end

    # @rbs () -> void
    def headline
      json['headline']
    end

    # @rbs () -> void
    def description
      json['description']
    end

    # @rbs () -> void
    def language
      lang = json['inLanguage']
      lang = lang.first if lang.is_a?(Array)
      lang.is_a?(Hash) ? (lang['alternateName'] || lang['name']) : lang
    end

    def type
      json['@type']
    end

    def image
      obj = first_of_value(json['image'])

      return obj['url'] if obj.is_a?(Hash)

      obj
    end

    # @rbs () -> void
    def date_published
      json['datePublished']
    end

    def date_modified
      json['dateModified']
    end

    # @rbs () -> void
    def author_name
      name = author['name']
      name.is_a?(Array) ? name.join(', ') : name
    end

    def author_url
      author['url']
    end

    # @rbs () -> void
    def publisher_name
      publisher['name']
    end

    def publisher_logo
      publisher.dig('logo', 'url')
    end

    # @rbs () -> void
    def valid?
      json.present?
    end

    private

    # @rbs () -> Hash[untyped, untyped]
    def author
      first_of_value(json['author']) || {}
    end

    # @rbs () -> Hash[untyped, untyped]
    def publisher
      first_of_value(json['publisher']) || {}
    end

    # @rbs (Hash[untyped, untyped]) -> void
    def first_of_value(arr)
      arr.is_a?(Array) ? arr.first : arr
    end

    # @rbs ((Hash[untyped, untyped] | Array[untyped])?) -> Array[untyped]
    def root_array(root)
      root.is_a?(Array) ? root : [root]
    end

    # @rbs () -> Hash[untyped, untyped]?
    def json
      @json ||= root_array(Oj.load(@data)).compact.find { |obj| SUPPORTED_TYPES.include?(obj['@type']) } || {}
    end
  end

  # @rbs (String, String, String?) -> void
  def initialize(original_url, html, html_charset)
    @original_url = Addressable::URI.parse(original_url)
    @html         = html
    @html_charset = html_charset
  end

  # @rbs () -> void
  def to_preview_card_attributes
    {
      title: title || '',
      description: description || '',
      image_remote_url: image,
      image_description: image_alt || '',
      type: type,
      link_type: link_type,
      width: width || 0,
      height: height || 0,
      html: html || '',
      provider_name: provider_name || '',
      provider_url: provider_url || '',
      author_name: author_name || '',
      author_url: author_url || '',
      embed_url: embed_url || '',
      language: language,
      published_at: published_at.presence,
    }
  end

  # @rbs () -> void
  def type
    player_url.present? ? :video : :link
  end

  # @rbs () -> void
  def link_type
    if structured_data&.type == 'NewsArticle' || opengraph_tag('og:type') == 'article'
      :article
    else
      :unknown
    end
  end

  # @rbs () -> void
  def html
    player_url.present? ? content_tag(:iframe, nil, src: player_url, width: width, height: height, allowfullscreen: 'true', allowtransparency: 'true', scrolling: 'no', frameborder: '0') : nil
  end

  # @rbs () -> void
  def width
    opengraph_tag('twitter:player:width')
  end

  # @rbs () -> void
  def height
    opengraph_tag('twitter:player:height')
  end

  # @rbs () -> (String | void)
  def title
    html_entities.decode(structured_data&.headline || opengraph_tag('og:title') || head.at_xpath('title')&.content)&.strip
  end

  # @rbs () -> (String | void)
  def description
    html_entities.decode(structured_data&.description || opengraph_tag('og:description') || meta_tag('description'))
  end

  # @rbs () -> String?
  def published_at
    structured_data&.date_published || opengraph_tag('article:published_time')
  end

  # @rbs () -> (String | void)
  def image
    valid_url_or_nil(opengraph_tag('og:image'))
  end

  # @rbs () -> (String | void)
  def image_alt
    opengraph_tag('og:image:alt')
  end

  # @rbs () -> (String | void)
  def canonical_url
    valid_url_or_nil(link_tag('canonical') || opengraph_tag('og:url'), same_origin_only: true) || @original_url.to_s
  end

  # @rbs () -> (String | void)
  def provider_name
    html_entities.decode(structured_data&.publisher_name || opengraph_tag('og:site_name'))
  end

  # @rbs () -> void
  def provider_url
    valid_url_or_nil(host_to_url(opengraph_tag('og:site')))
  end

  # @rbs () -> (String | void)
  def author_name
    html_entities.decode(structured_data&.author_name || opengraph_tag('og:author') || opengraph_tag('og:author:username'))
  end

  # @rbs () -> void
  def author_url
    structured_data&.author_url
  end

  # @rbs () -> void
  def author_account
    opengraph_tag('fediverse:creator')
  end

  # @rbs () -> void
  def embed_url
    valid_url_or_nil(opengraph_tag('twitter:player:stream'))
  end

  # @rbs () -> (String | void)
  def language
    valid_locale_or_nil(structured_data&.language || opengraph_tag('og:locale') || document.root.attr('lang'))
  end

  # @rbs () -> String
  def icon
    valid_url_or_nil(structured_data&.publisher_icon || link_tag('apple-touch-icon') || link_tag('icon'))
  end

  private

  # @rbs () -> nil
  def player_url
    valid_url_or_nil(opengraph_tag('twitter:player'))
  end

  # @rbs (nil) -> void
  def host_to_url(str)
    return if str.blank?

    str.start_with?(%r{https?://}) ? str : "http://#{str}"
  end

  # @rbs (String?, ?same_origin_only: bool) -> void
  def valid_url_or_nil(str, same_origin_only: false)
    return if str.blank? || str == 'null' || str == 'undefined'

    url = @original_url + Addressable::URI.parse(str)

    return if url.host.blank? || !%w(http https).include?(url.scheme) || (same_origin_only && url.host != @original_url.host)

    url.to_s
  rescue Addressable::URI::InvalidURIError
    nil
  end

  # @rbs (String) -> void
  def link_tag(name)
    head.at_xpath("//link[nokogiri:link_rel_include(@rel, '#{name}')]", NokogiriHandler)&.attr('href')
  end

  # @rbs (String) -> void?
  def opengraph_tag(name)
    head.at_xpath("//meta[nokogiri:casecmp(@property, '#{name}') or nokogiri:casecmp(@name, '#{name}')]", NokogiriHandler)&.attr('content')
  end

  # @rbs (String) -> void
  def meta_tag(name)
    head.at_xpath("//meta[nokogiri:casecmp(@name, '#{name}')]", NokogiriHandler)&.attr('content')
  end

  # @rbs () -> LinkDetailsExtractor::StructuredData?
  def structured_data
    return @structured_data if defined?(@structured_data)

    # Some publications have more than one JSON-LD definition on the page,
    # and some of those definitions aren't valid JSON either, so we have
    # to loop through here until we find something that is the right type
    # and doesn't break
    @structured_data ||= document.xpath('//script[@type="application/ld+json"]').filter_map do |element|
      json_ld = element.content&.gsub(CDATA_JUNK_PATTERN, '')

      next if json_ld.blank?

      structured_data = StructuredData.new(html_entities.decode(json_ld))

      next unless structured_data.valid?

      structured_data
    rescue Oj::ParseError, EncodingError
      Rails.logger.debug { "Invalid JSON-LD in #{@original_url}" }
      next
    end.first
  end

  # @rbs () -> Nokogiri::HTML5::Document
  def document
    @document ||= detect_encoding_and_parse_document
  end

  # @rbs () -> Nokogiri::XML::Element
  def head
    @head ||= document.at_xpath('/html/head')
  end

  # @rbs () -> Nokogiri::HTML5::Document
  def detect_encoding_and_parse_document
    html = nil
    encoding = nil

    [detect_encoding, header_encoding].compact.each do |enc|
      html = @html.dup.force_encoding(enc)
      if html.valid_encoding?
        encoding = enc
        break
      end
    end

    html = @html unless encoding

    Nokogiri::HTML5(html, nil, encoding)
  end

  # @rbs () -> void
  def detect_encoding
    guess = detector.detect(@html, @html_charset)
    guess&.fetch(:confidence, 0).to_i > 60 ? guess&.fetch(:encoding, nil) : nil
  end

  # @rbs () -> void
  def header_encoding
    Encoding.find(@html_charset).name if @html_charset
  rescue ArgumentError
    # Encoding from HTTP header is not recognized by ruby
    nil
  end

  # @rbs () -> CharlockHolmes::EncodingDetector
  def detector
    @detector ||= CharlockHolmes::EncodingDetector.new.tap do |detector|
      detector.strip_tags = true
    end
  end

  # @rbs () -> HTMLEntities
  def html_entities
    @html_entities ||= HTMLEntities.new(:expanded)
  end
end
