require 'tempfile'

require 'gosu'
require 'texplay'

require 'gale'

module Gosu
  class Color
    class << self
      # Create Color from an opaque color from a Graphics Gale file.
      # @param color [Integer] 0xrrggbb
      def from_gale(color)
        rgb (color >> 16) & 0xff, (color >> 8) & 0xff, color & 0xff
      end
    end
  end
end

module Gale
  class File
    # @option :column [Integer] (Float::INFINITY) Max number of columns to use.
    # @return Gosu::Image
    def to_spritesheet(options = {})
      columns = options[:columns] || Float::INFINITY
      columns = [columns, size].min
      rows = size.fdiv(columns).ceil

      sheet = TexPlay.create_image $window, columns * width, rows * height, :caching => true
      each do |frame|
        row, column = frame.index.divmod columns
        sheet.splice frame.to_image, column * width, row * height
      end
      sheet
    end
  end

  class Frame
    # @return Gosu::Image
    def to_image
      # Hack because I have no idea how to make #to_blob properly.
      file = Tempfile.new 'gale_bitmap'
      image = nil
      begin
        file.close # Don't actually use it directly, since we are going to overwrite it.
        export_bitmap file.path

        image = Gosu::Image.new $window, file.path, :caching => true
        if transparent_color?
          image.clear :dest_select => Gosu::Color.from_gale(transparent_color), :tolerance => 0.001
        end
      ensure
        file.unlink
      end

      image
    end
  end

  class Layer
    # @return Gosu::Image
    def to_image
      # Hack because I have no idea how to make #to_blob properly.
      file = Tempfile.new 'gale_bitmap'
      image = nil
      begin
        file.close # Don't actually use it directly, since we are going to overwrite it.
        export_bitmap file.path

        image = Gosu::Image.new $window, file.path, :caching => true
        if transparent_color?
          image.clear :dest_select => Gosu::Color.from_gale(transparent_color), :tolerance => 0.001
        end
      ensure
        file.unlink
      end

      image
    end
  end
end