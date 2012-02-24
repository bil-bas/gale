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
          # We want only to clear the alpha channel, not the whole bit to transparent black.
          color_to_replace = Gosu::Color.from_gale(transparent_color)
          replace_with = color_to_replace.dup
          replace_with.alpha = 0
          image.clear :dest_select => color_to_replace, :tolerance => 0.001, :color => replace_with
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
      bitmap = Tempfile.new 'gale_bitmap'
      alpha_channel = alpha_channel? ? Tempfile.new('gale_alpha_channel') : nil
      image = nil
      begin
        bitmap.close # Don't actually use it directly, since we are going to overwrite it.
        export_bitmap bitmap.path

        if alpha_channel
          alpha_channel.close
          export_alpha_channel alpha_channel.path
        end

        image = Gosu::Image.new options[:window], bitmap.path, :caching => true
        if alpha_channel?
          # Multiply by alpha channel image.
          ac_image = Gosu::Image.new options[:window], alpha_channel.path, :caching => true
          image.splice ac_image, 0, 0, :color_control => lambda {|pixel, alpha|
            # alpha will be black to white (transparent to opaque).
            pixel[3] *= alpha[0]
            pixel
          }
        end

        if transparent_color?
          color_to_replace = Gosu::Color.from_gale(transparent_color)
          replace_with = color_to_replace.dup
          replace_with.alpha = 0
          image.clear :dest_select => color_to_replace, :tolerance => 0.001, :color => replace_with
        end

        # Fade out if opacity is low.
        if opacity < 255
          factor = opacity / 255.0
          image.each do |c|
            c[3] *= factor
            c
          end
        end
      ensure
        bitmap.unlink
        alpha_channel.unlink if alpha_channel
      end

      image
    end
  end
end