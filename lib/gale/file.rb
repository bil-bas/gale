module Gale
  class FormatError < StandardError; end

  # A GraphicsGale image, containing Frames and Layers.
  class File
    include Enumerable

    attr_reader :handle

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

      num_frames = Dll.frame_count @handle
      @frames = num_frames.times.map {|i| Frame.new self, i }

      if block_given?
        begin
          yield self
        ensure
          close
        end
      end
    end

    def each(&block)
      @frames.each(&block)
    end

    def size
      @frames.size
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

    # @option :column [Integer] (Float::INFINITY) Max number of columns to use.
    def to_spritesheet(options = {})
      columns = options[:columns] || Float::INFINITY
      columns = [columns, size].min
      rows = size.fdiv(columns).ceil

      sheet = TexPlay.create_image $window, columns * width, rows * height
      each do |frame|
        row, column = frame.index.divmod columns
        sheet.splice frame.to_image, column * width, row * height
      end
      sheet
    end
  end
end