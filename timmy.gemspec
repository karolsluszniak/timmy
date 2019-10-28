lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "timmy/version"

Gem::Specification.new do |spec|
  spec.name          = "timmy"
  spec.version       = Timmy::VERSION
  spec.authors       = ["Karol Słuszniak"]
  spec.email         = ["ksluszniak@gmail.com"]

  spec.summary       = "Time execution of command and its stages marked by console output"
  spec.homepage      = "https://github.com/karolsluszniak/timmy"
  spec.license       = "MIT"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
