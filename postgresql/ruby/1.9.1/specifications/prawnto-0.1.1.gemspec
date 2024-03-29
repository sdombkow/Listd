# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "prawnto"
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["smecsia", "niquola", "bondarev"]
  s.date = "2012-04-09"
  s.description = "Support .prawn templates as Prawn::Document content"
  s.email = ["smecsia@gmail.com", "alexander.i.bondarev@gmail.com"]
  s.homepage = "https://github.com/smecsia/prawnto"
  s.require_paths = ["lib"]
  s.rubyforge_project = "prawnto"
  s.rubygems_version = "1.8.25"
  s.summary = "Support .prawn templates as Prawn::Document content"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<prawn>, [">= 0"])
      s.add_runtime_dependency(%q<rails>, [">= 2.1"])
    else
      s.add_dependency(%q<prawn>, [">= 0"])
      s.add_dependency(%q<rails>, [">= 2.1"])
    end
  else
    s.add_dependency(%q<prawn>, [">= 0"])
    s.add_dependency(%q<rails>, [">= 2.1"])
  end
end
