module Gale
  class Layer
    attr_reader :file, :frame, :index

    def initialize(file, frame, index)
      @file, @frame, @index = file, frame, index
    end

    def name
      buffer = FFI::Buffer.new STRING_BUFFER_SIZE
      length = Dll.layer_name file.handle, frame.index, index, buffer, buffer.size
      buffer.get_string 0
    end

    def transparent_color
      color = Dll.layer_info file.handle, frame.index, index, Dll::FrameInfo::TRANSPARENT_COLOR
      Gosu::Color.rgb (color >> 16) & 0xff, (color >> 8) & 0xff, color & 0xff
    end

    def export_bitmap(filename)
      result = Dll.export_bitmap file.handle, frame.index, index, filename
      raise "Export failed" if result == 0
      nil
    end

    def to_image
      # Hack because I have no idea how to make #to_blob properly.
      export_bitmap TMP_BITMAP

      begin
        image = Gosu::Image.new $window, Gale::TMP_BITMAP
        image.clear :dest_select => transparent_color, :tolerance => 0.001
      ensure
        ::File.delete TMP_BITMAP
      end

      image
    end

    def export_alpha_channel(filename)
      result = Dll.export_alpha_channel file.handle, frame.index, index, filename
      raise "Export failed" if result == 0
      nil
    end
  end
end