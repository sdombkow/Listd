# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "prawnto/version"

Gem::Specification.new do |s|
  s.name        = "prawnto"
  s.version     = Prawnto::VERSION
  s.authors     = ["smecsia", "niquola", "bondarev"]
  s.email       = ["smecsia@gmail.com", "alexander.i.bondarev@gmail.com"]
  s.homepage    = "https://github.com/smecsia/prawnto"
  s.summary     = %q{Support .prawn templates as Prawn::Document content}
  s.description = %q{Support .prawn templates as Prawn::Document content}

  s.rubyforge_project = "prawnto"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "prawn"
  s.add_runtime_dependency 'rails', '>=2.1'
end
