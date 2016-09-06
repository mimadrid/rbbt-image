# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: rbbt-image 0.1.13 ruby lib

Gem::Specification.new do |s|
  s.name = "rbbt-image"
  s.version = "0.1.13"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Miguel Vazquez"]
  s.date = "2016-09-06"
  s.description = "Builds provision files for docker and Vagrant and helps run them"
  s.email = "miguel.vazquez@cnio.es"
  s.executables = ["build_rbbt_provision_sh.rb", "run_rbbt_docker.rb"]
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    "Dockerfile",
    "Vagrantfile",
    "lib/rbbt/docker.rb",
    "share/provision_scripts/bootstrap.sh",
    "share/provision_scripts/gem_setup.sh",
    "share/provision_scripts/ruby_setup.sh",
    "share/provision_scripts/ubuntu_setup.sh",
    "share/provision_scripts/user_setup.sh",
    "share/provision_scripts/variables.sh"
  ]
  s.homepage = "http://github.com/mikisvaz/rbbt-image"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.6"
  s.summary = "Build docker and Vagrant (VM) images"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rbbt-util>, [">= 0"])
    else
      s.add_dependency(%q<rbbt-util>, [">= 0"])
    end
  else
    s.add_dependency(%q<rbbt-util>, [">= 0"])
  end
end

