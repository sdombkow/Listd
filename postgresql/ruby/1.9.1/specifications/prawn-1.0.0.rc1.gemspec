# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "prawn"
  s.version = "1.0.0.rc1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["Gregory Brown", "Brad Ediger", "Daniel Nelson", "Jonathan Greenberg", "James Healy"]
  s.date = "2011-10-11"
  s.description = "  Prawn is a fast, tiny, and nimble PDF generator for Ruby\n"
  s.email = ["gregory.t.brown@gmail.com", "brad@bradediger.com", "dnelson@bluejade.com", "greenberg@entryway.net", "jimmy@deefa.com"]
  s.extra_rdoc_files = ["README.md", "LICENSE", "COPYING", "GPLv2", "GPLv3"]
  s.files = ["README.md", "LICENSE", "COPYING", "GPLv2", "GPLv3"]
  s.homepage = "http://prawn.majesticseacreature.com"
  s.post_install_message = "\n********************************************\n\n\nA lot has changed recently in Prawn.\n\nPlease read the changelog for details:\n\nhttps://github.com/sandal/prawn/wiki/CHANGELOG\n\n\n********************************************\n\n"
  s.rdoc_options = ["--title", "Prawn Documentation", "--main", "README.md", "-q"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.rubyforge_project = "prawn"
  s.rubygems_version = "1.8.25"
  s.summary = "A fast and nimble PDF generator for Ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<pdf-reader>, [">= 0.9.0"])
      s.add_runtime_dependency(%q<ttfunk>, ["~> 1.0.3"])
      s.add_development_dependency(%q<pdf-inspector>, ["~> 1.0.1"])
    else
      s.add_dependency(%q<pdf-reader>, [">= 0.9.0"])
      s.add_dependency(%q<ttfunk>, ["~> 1.0.3"])
      s.add_dependency(%q<pdf-inspector>, ["~> 1.0.1"])
    end
  else
    s.add_dependency(%q<pdf-reader>, [">= 0.9.0"])
    s.add_dependency(%q<ttfunk>, ["~> 1.0.3"])
    s.add_dependency(%q<pdf-inspector>, ["~> 1.0.1"])
  end
end
