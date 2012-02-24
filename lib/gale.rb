require 'gale/dll'

require 'gale/layer'
require 'gale/frame'
require 'gale/file'

module Gale
  STRING_BUFFER_SIZE = 256
  TMP_BITMAP = (ENV['TMP'] || ENV['TEMP']) + "/tmp.bmp"
end