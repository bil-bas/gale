module Gale
  class Frame
    include Enumerable
    attr_reader :file, :index

    def initialize(file, index)
      @file, @index = file, index

      num_layers = Dll.layer_count file.send(:handle), index
      @layers = num_layers.times.map {|i| Layer.new file, self, i }
    end

    def each_layer(&block)
      @layers.each(&block)
    end

    alias_method :each, :each_layer

    def size
      @layers.size
    end

    def [](layer_index)
      @layers[layer_index]
    end

    def name
      @name ||= begin
        buffer = FFI::Buffer.new Dll::STRING_BUFFER_SIZE
        length = Dll.frame_name file.send(:handle), index, buffer, buffer.size
        buffer.get_string 0, length
      end
    end

    def delay
      @delay ||= Dll.frame_info file.send(:handle), index, Dll::FrameInfo::DELAY_MS
    end

    def transparent_color
      @transparent_color ||= Dll.frame_info file.send(:handle), index, Dll::FrameInfo::TRANSPARENT_COLOR
    end

    # @return [:none, :no_disposal, :background, :previous]
    def disposal
      @disposal ||= begin
        value = Dll.frame_info file.send(:handle), index, Dll::FrameInfo::DISPOSAL
        case value
          when Dll::FrameInfo::Disposal::NOT_SPECIFIED
            :none
          when Dll::FrameInfo::Disposal::NOT_DISPOSED
            :no_disposal
          when Dll::FrameInfo::Disposal::BACKGROUND_FILL
            :background
          when Dll::FrameInfo::Disposal::RESTORE_PREVIOUS
            :previous
          else
            raise "Unknown disposal value #{value}"
        end
      end
    end

    def export_bitmap(filename)
      result = Dll.export_bitmap file.send(:handle), index, -1, filename
      raise "Export failed" if result == 0
      nil
    end
  end
end