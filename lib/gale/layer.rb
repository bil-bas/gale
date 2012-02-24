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

    def visible?
      @visible ||= Dll.layer_info(file.send(:handle), frame.index, index, Dll::LayerInfo::VISIBLE) == Dll::TRUE
    end

    def alpha_channel?
      @alpha_channel ||= Dll.layer_info(file.send(:handle), frame.index, index, Dll::LayerInfo::ALPHA_CHANNEL) == Dll::TRUE
    end

    # Layer opacity
    # @return [Integer] 0..255 for transparent to opaque.
    def opacity
      @opacity ||= Dll.layer_info file.send(:handle), frame.index, index, Dll::LayerInfo::OPACITY
    end

    # @return [Integer, nil] 0xRRGGBB or nil if transparency disabled.
    def transparent_color
      @transparent_color ||= begin
        value = Dll.layer_info file.send(:handle), frame.index, index, Dll::LayerInfo::TRANSPARENT_COLOR
        value == -1 ? nil : value
      end
    end

    # @return [Boolean] true if a transparent color has been set.
    def transparent_color?
      not transparent_color.nil?
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