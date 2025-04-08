# frozen_string_literal: true

class FastGeometryParser
  # @rbs (Paperclip::FileAdapter | Paperclip::Tempfile | Paperclip::AttachmentAdapter | File | Paperclip::DataUriAdapter | Paperclip::UploadedFileAdapter) -> Paperclip::Geometry
  def self.from_file(file)
    width, height = FastImage.size(file)

    raise Paperclip::Errors::NotIdentifiedByImageMagickError if width.nil?

    Paperclip::Geometry.new(width, height)
  end
end
