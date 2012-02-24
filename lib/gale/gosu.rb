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
    # Create a sprite-sheet from the frames in the File. By default, this will be a horizontal strip.
    #
    # @option :columns [Integer] (#size) Number of columns to use. Will leave excess columns empty.
    # @option :window [Gosu::Window] ($window) Window used to create the image.
    # @return Gosu::Image
    def to_spritesheet(options = {})
      options = {
          :columns => size,
          :window => $window,
      }.merge! options

      columns = options[:columns]
      rows = size.fdiv(columns).ceil

      sheet = TexPlay.create_image options[:window], columns * width, rows * height, :caching => true
      each do |frame|
        row, column = frame.index.divmod columns
        sheet.splice frame.to_image, column * width, row * height
      end
      sheet
    end
  end

  class Frame
    # @option :window [Gosu::Window] ($window) Window used to create the image.
    # @return Gosu::Image
    def to_image(options = {})
      options = {
          :window => $window,
      }.merge! options

      # Hack because I have no idea how to make #to_blob properly.
      file = Tempfile.new 'gale_bitmap'
      image = nil
      begin
        file.close # Don't actually use it directly, since we are going to overwrite it.
        export_bitmap file.path

        image = Gosu::Image.new options[:window], file.path, :caching => true
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
    # @option :window [Gosu::Window] ($window) Window used to create the image.
    # @return Gosu::Image
    def to_image(options = {})
      options = {
          :window => $window,
      }.merge! options

      # Hack because I have no idea how to make #to_blob properly.
      file = Tempfile.new 'gale_bitmap'
      image = nil
      begin
        file.close # Don't actually use it directly, since we are going to overwrite it.
        export_bitmap file.path

        image = Gosu::Image.new options[:window], file.path, :caching => true
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