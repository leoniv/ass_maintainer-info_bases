# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ass_maintainer/info_bases/version"

Gem::Specification.new do |spec|
  spec.name          = "ass_maintainer-info_bases"
  spec.version       = AssMaintainer::InfoBases::VERSION
  spec.authors       = ["Leonid Vlasov"]
  spec.email         = ["leoniv.vlasov@gmail.com"]

  spec.summary       = %q{Provides infobase classes proper for various use cases}
  spec.description   = %q{More about infobase see https://github.com/leoniv/ass_maintainer-info_base}
  spec.homepage      = "https://github.com/leoniv/ass_maintainer-info_bases"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "ass_maintainer-info_base", '~> 1.0'

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "mocha"
end
