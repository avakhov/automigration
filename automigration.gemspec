# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "automigration/version"

Gem::Specification.new do |s|
  s.name        = "automigration"
  s.version     = Automigration::VERSION
  s.authors     = ["Alexey Vakhov"]
  s.email       = ["vakhov@gmail.com"]
  s.homepage    = "https://github.com/aperio-it/automigration"
  s.summary     = %q{AR automigration}
  s.description = %q{Store your migrations direct in models}

  s.rubyforge_project = "automigration"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'rails', '~> 3.1'
  s.add_development_dependency 'pg'
end
