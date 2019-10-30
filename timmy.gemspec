lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "timmy/version"

Gem::Specification.new do |spec|
  spec.name          = "timmy"
  spec.version       = Timmy::VERSION
  spec.authors       = ["Karol Słuszniak"]
  spec.email         = ["ksluszniak@gmail.com"]

  spec.summary       = "Time execution of commands and their stages based on console output"
  spec.homepage      = "https://github.com/karolsluszniak/timmy"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*.rb"] + ["bin/timmy"]
  spec.bindir        = "bin"
  spec.executables   = ["timmy"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
