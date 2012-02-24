module Gale
  class Frame
    include Enumerable
    attr_reader :file, :index

    def initialize(file, index)
      @file, @index = file, index

      num_layers = Dll.layer_count file.handle, index
      @layers = num_layers.times.map {|i| Layer.new file, self, i }
    end

    def each(&block)
      @layers.each(&block)
    end

    def size
      @layers.size
    end

    def [](layer_index)
      @layers[layer_index]
    end

    def name
      buffer = FFI::Buffer.new Gale::STRING_BUFFER_SIZE
      length = Dll.frame_name file.handle, index, buffer, buffer.size
      buffer.get_string 0
    end

    def delay
      Dll.frame_info file.handle, index, Dll::FrameInfo::DELAY_MS
    end

    def transparent_color
      color = Dll.frame_info file.handle, index, Dll::FrameInfo::TRANSPARENT_COLOR
      Gosu::Color.rgb (color >> 16) & 0xff, (color >> 8) & 0xff, color & 0xff
    end

    def export_bitmap(filename)
      result = Dll.export_bitmap file.handle, index, -1, filename
      raise "Export failed" if result == 0
      nil
    end

    def to_image
      # Hack because I have no idea how to make #to_blob properly.
      export_bitmap Gale::TMP_BITMAP

      begin
        image = Gosu::Image.new $window, Gale::TMP_BITMAP
        image.clear :dest_select => transparent_color, :tolerance => 0.001
      ensure
        ::File.delete Gale::TMP_BITMAP
      end

      image
    end
  end
end