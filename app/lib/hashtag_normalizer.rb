# frozen_string_literal: true

class HashtagNormalizer
  # @rbs (String) -> (void | String)
  def normalize(str)
    remove_invalid_characters(ascii_folding(lowercase(cjk_width(str))))
  end

  private

  # @rbs (String) -> void
  def remove_invalid_characters(str)
    str.gsub(Tag::HASHTAG_INVALID_CHARS_RE, '')
  end

  # @rbs (String) -> void
  def ascii_folding(str)
    ASCIIFolding.new.fold(str)
  end

  # @rbs (String) -> void
  def lowercase(str)
    str.mb_chars.downcase.to_s
  end

  # @rbs (String) -> void
  def cjk_width(str)
    str.unicode_normalize(:nfkc)
  end
end
