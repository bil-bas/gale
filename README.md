Gale
====

Ruby gem to read info and data from a Graphics Gale (.gal) animation file.

Note: Only works on Windows and requires the Graphics Gale DLL (galefile.dll),
available for download from http://www.humanbalance.net/gale/us/
(I have to ask for permission to distribute it with the gem, but haven't had a reply yet).

* Author: Spooner / Bil Bas (bil.bagpuss@gmail.com)
* License: MIT

Installation
------------

    gem install gale

Examples
--------

    # By default, gale has no external dependencies, but can only export bitmaps.
    require 'gale'
    animation = Gale::File.open "jumping.gal" do
      puts animation.size                                           #=> 3, which is the number of frames.
      puts [animation.width, animation.height]                      #=> [64, 32]
      puts animation[0].name                                        #=> "Dog getting ready to jump"
      puts animation[0][0].name                                     #=> "Dog's Body"
      animation[0].export_bitmap "jump_0.bmp"                       # Saves the first frame as a bitmap.
      animation[0][0].export_alpha_channel "jump_0_0_alpha.bmp"     # Saves the first layer's alpha channel
      animation[0][0].export_bitmap "jump_0_0.bmp"                  # Saves the first layer as a bitmap.
      animation.export_yaml "jump.yml", [:name, :delay]             # Saves a YAML data file containing info about each frame.
    end

    # If using Gosu/TexPlay, then it is possible to export directly to a Gosu::Image, with transparency.
    require 'gale/gosu' # Will require the gosu and texplay gems for you.
    animation = Gale::File.open "jumping.gal" do
      gosu_frame = animation[0].to_image                            #=> a Gosu::Image, being the first frame.
      gosu_layer = animation[0][0].to_image                         #=> a Gosu::Image, being the first layer.
      gosu_frames = animation.map {|f| f.to_image }                 #=> Array of Gosu::Image, one for each frame.

      gosu_spritesheet = animation.to_spritesheet                   #=> a Gosu::Image, being a horizontal series of frames.
      gosu_spritesheet.save "jumping.png"                           # Gosu images can be saved in png or bmp format.

      gosu_color = Gosu::Color.from_gale animation.background_color #=> a Gosu::Color
    end