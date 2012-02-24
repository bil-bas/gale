Gale
====

Ruby gem to read info and data from a Graphics Gale (.gal) animation file.

Note: Only works on Windows and requires the galefile.dll

* Author: Spooner / Bil Bas (bil.bagpuss@gmail.com)
* License: MIT

Installation
------------

    gem install gale

Usage
-----

    animation = Gale::File.new "jumping.gal"
    puts animation.size #=> 3, which is the number of frames.
    animation[0].export_bitmap "jumping_0.bmp" # Saves the first frame as a bitmap.
    animation.to_spritesheet.save "jumping.png" # Export as a Gosu image and save it as a png.