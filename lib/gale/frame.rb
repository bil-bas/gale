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
        buffer = FFI::Buffer.new Gale::STRING_BUFFER_SIZE
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

    def export_bitmap(filename)
      result = Dll.export_bitmap file.send(:handle), index, -1, filename
      raise "Export failed" if result == 0
      nil
    end
  end
end