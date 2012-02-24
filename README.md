Gale
====

Ruby gem to read info and data from a Graphics Gale (.gal) animation file.

Note: Only works on Windows and requires the galefile.dll

* Author: Spooner
* License: MIT

Installation
------------

    gem install gale

Usage
-----

   animation = Gale::File.new "jumping.gal"
   puts animation.num_frames #=> 3
   animation.export_bitmap "jumping_0.bmp", 0 # Saves the first frame as a bitmap.