require 'gosu'
require 'texplay'

module Gale
  class FormatError < StandardError; end

  # A GraphicsGale image, containing Frames and Layers.
  class File
    STRING_BUFFER_SIZE = 256

    def initialize(filename)
      @handle = Dll.open filename
      if @handle.null?
        case Dll.last_error
          when Dll::Error::FILE_NOT_FOUND
            raise Errno::ENOENT, "File not found: #{filename}"
          when Dll::Error::BAD_FORMAT
            raise FormatError, "File not in GraphicsGale format: #{filename}"
          else
            raise "Unknown error opening: #{filename}"
        end
      end
    end

    def num_frames
      Dll.frame_count @handle
    end
    
    def frame_name(frame_index)
      buffer = FFI::Buffer.new STRING_BUFFER_SIZE
      length = Dll.frame_name @handle, frame_index, buffer, buffer.size
      buffer.get_string 0
    end
    
    def frame_delay(frame_index)
      Dll.frame_info @handle, frame_index, Dll::FrameInfo::DELAY_MS
    end
    
    def frame_transparent_color(frame_index)
      color = Dll.frame_info @handle, frame_index, Dll::FrameInfo::TRANSPARENT_COLOR
      Gosu::Color.rgb (color >> 16) & 0xff, (color >> 8) & 0xff, color & 0xff
    end
    
    def layer_name(frame_index, layer_index)
      buffer = FFI::Buffer.new STRING_BUFFER_SIZE
      length = Dll.layer_name @handle, frame_index, layer_index, buffer, buffer.size
      buffer.get_string 0
    end

    def num_layers(frame_index)
      Dll.layer_count @handle, frame_index
    end

    def close
      Dll.close @handle
    end
    
    def height; Dll.info @handle, Dll::Info::HEIGHT; end
    def width; Dll.info @handle, Dll::Info::WIDTH; end
    def bits_per_pixel; Dll.info @handle, Dll::Info::BPP; end
    def background_color
      # BUG: assumes 24-bit.
      color = Dll.info @handle, Dll::Info::BACKGROUND_COLOR
      Gosu::Color.rgb (color >> 16) & 0xff, (color >> 8) & 0xff, color & 0xff
    end
    
    # layer -1 gives the combined image of the frame.
    def to_blob(frame_index, layer_index = -1)
      hbitmap = Dll.bitmap @handle, frame_index, layer_index
      palette = Dll.palette @handle, frame_index
      bitmap = GDIPlus.from_hbitmap hbitmap, palette
      p bitmap
      #bitmap.values[:bits].get_string 0, (bitmap.bits_per_pixel / 8) * bitmap.height * bitmap.width
      nil
    end  

    # layer -1 gives the combined image of the frame.
    def export_bitmap(filename, frame_index, layer_index = -1)
      result = Dll.export_bitmap @handle, frame_index, layer_index, filename
      raise "Export failed" if result == 0
      nil
    end

    def export_alpha_channel(filename, frame_index, layer_index)
      result = Dll.export_alpha_channel @handle, frame_index, layer_index, filename
      raise "Export failed" if result == 0
      nil
    end
  end
end