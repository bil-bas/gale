module Gale
  class Layer
    attr_reader :file, :frame, :index

    def initialize(file, frame, index)
      @file, @frame, @index = file, frame, index
    end

    def name
      @name ||= begin
        buffer = FFI::Buffer.new Dll::STRING_BUFFER_SIZE
        length = Dll.layer_name file.send(:handle), frame.index, index, buffer, buffer.size
        buffer.get_string 0, length
      end
    end

    def transparent_color
      @transparent_color ||= Dll.layer_info file.send(:handle), frame.index, index, Dll::FrameInfo::TRANSPARENT_COLOR
    end

    def export_bitmap(filename)
      result = Dll.export_bitmap file.send(:handle), frame.index, index, filename
      raise "Export failed" if result == 0
      nil
    end

    def export_alpha_channel(filename)
      result = Dll.export_alpha_channel file.send(:handle), frame.index, index, filename
      raise "Export failed" if result == 0
      nil
    end
  end
end