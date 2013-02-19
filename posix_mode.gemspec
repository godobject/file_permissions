# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "god_object/posix_mode/version"

Gem::Specification.new do |s|
  s.name        = "posix_mode"
  s.version     = GodObject::PosixMode::VERSION.dup
  s.authors     = ["Alexander E. Fischer", "Oliver Feldt"]
  s.email       = ["aef@raxys.net", "oliver.feldt@gmail.com"]
  s.homepage    = "https://aef.name"
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec', '2.12.0'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'yard'
  s.add_dependency 'bit_set'
end
