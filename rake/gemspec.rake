# -*- encoding: utf-8 -*-

GEMSPEC_FILE =
task :gemspec do
  generate_gemspec
end

file "gale.gemspec" do
  generate_gemspec
end

def generate_gemspec
  puts "Generating gemspec"

  require_relative "../lib/gale/version"

  spec = Gem::Specification.new do |s|
    s.name = "gale"
    s.version = Gale::VERSION

    s.platform    = Gem::Platform.local
    s.authors     = ["Bil Bas (Spooner)"]
    s.email       = ["bil.bagpuss@gmail.com"]
    s.homepage    = "http://spooner.github.com/libraries/gale/"
    s.summary     = %q{Read Graphics Gale (.gal) files}

    # TODO: Add the DLL when permission is granted.
    s.files = Dir[*%w<lib/**/* test/**/* *.md *.txt>]
    s.licenses = ["MIT"]
    s.rubyforge_project = s.name

    s.test_files = Dir["test/**/*_spec.rb"]

    s.add_runtime_dependency "ffi", "= 1.0.9" # Later versions bugged on Windows.
    s.add_runtime_dependency "gosu", "~> 0.7.41"
    s.add_runtime_dependency "texplay", "~> 0.3.5" # latest doesn't compile on Windows.

    s.add_development_dependency "rake", "~> 0.9.2.2"
    s.add_development_dependency "rspec", "~> 2.8.0"
    s.add_development_dependency "simplecov", "~> 0.6.0"
  end

  File.open("#{spec.name}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end