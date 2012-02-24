require 'bundler/setup'

require 'rspec'

$LOAD_PATH.unshift File.expand_path "../../lib", __FILE__

require "gale"

# Clean any previous test output.
ouput_directory = File.expand_path "../../test_output", __FILE__
Dir["#{ouput_directory}/*.*"].each {|f| File.delete f }
File.mkdir ouput_directory unless File.exists? ouput_directory