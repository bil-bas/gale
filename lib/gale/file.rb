module Gale
  class FormatError < StandardError; end

  # A GraphicsGale image, containing Frames and Layers.
  class File
    include Enumerable

    # Just for use by Frame/Layer
    attr_reader :handle
    protected :handle

    class << self
      alias_method :open, :new
    end

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

    def each_frame(&block)
      @frames.each(&block)
    end

    alias_method :each, :each_frame

    def size
      @frames.size
    end

    def [](frame_index)
      @frames[frame_index]
    end

    def close
      Dll.close @handle
      @handle = nil
    end
    
    def height; @height ||= Dll.info @handle, Dll::Info::HEIGHT; end
    def width; @width ||= Dll.info @handle, Dll::Info::WIDTH; end
    def bits_per_pixel; @bits_per_pixel ||= Dll.info @handle, Dll::Info::BPP; end

    def background_color
      @background_color ||= Dll.info @handle, Dll::Info::BACKGROUND_COLOR
    end

    def transparency_disabled?
      @transparency_disabled ||= begin
        value = Dll.info @handle, Dll::Info::TRANSPARENCY_DISABLED
        value == Dll::TRUE
      end
    end

    def palette_single?
      @palette_single ||= begin
        value = Dll.info @handle, Dll::Info::PALETTE_SINGLE
        value == Dll::TRUE
      end
    end
  end
end