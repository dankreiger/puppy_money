# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'puppy_money/version'

Gem::Specification.new do |spec|
  spec.name          = "puppy_money"
  spec.version       = PuppyMoney::VERSION
  spec.authors       = ["Dan Kreiger"]
  spec.email         = ["dan@dankreiger.com"]

  spec.summary       = %q{Easy currency conversion}
  spec.description   = %q{Convert currencies using live exchange rates.}
  spec.homepage      = "https://github.com/dankreiger/puppy_money"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # development
  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0.10"

  # runtime
  spec.add_runtime_dependency "httparty", "~> 0.14"
end
