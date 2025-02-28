# -*- encoding: utf-8 -*-
# stub: vagrant-vbguest 0.32.0 ruby lib

Gem::Specification.new do |s|
  s.name = "vagrant-vbguest".freeze
  s.version = "0.32.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/dotless-de/vagrant-vbguest/issues", "changelog_uri" => "https://github.com/dotless-de/vagrant-vbguest/blob/main/CHANGELOG.md", "documentation_uri" => "http://rubydoc.info/gems/vagrant-vbguest", "source_code_uri" => "https://github.com/dotless-de/vagrant-vbguest" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Robert Schulze".freeze]
  s.bindir = "exe".freeze
  s.date = "2023-12-17"
  s.description = "A Vagrant plugin which automatically installs the host's VirtualBox Guest Additions on the guest system.".freeze
  s.email = ["robert@dotless.de".freeze]
  s.homepage = "https://github.com/dotless-de/vagrant-vbguest".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0".freeze)
  s.rubygems_version = "3.3.26".freeze
  s.summary = "A Vagrant plugin to install the VirtualBoxAdditions into the guest VM".freeze

  s.installed_by_version = "3.3.26" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<micromachine>.freeze, [">= 2", "< 4"])
    s.add_runtime_dependency(%q<i18n>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<log4r>.freeze, [">= 0"])
  else
    s.add_dependency(%q<micromachine>.freeze, [">= 2", "< 4"])
    s.add_dependency(%q<i18n>.freeze, [">= 0"])
    s.add_dependency(%q<log4r>.freeze, [">= 0"])
  end
end
