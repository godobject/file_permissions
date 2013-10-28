# encoding: UTF-8
=begin
Copyright GodObject Team <dev@godobject.net>, 2012-2013

This file is part of PosixMode.

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
PERFORMANCE OF THIS SOFTWARE.
=end

require File.expand_path('../lib/god_object/posix_mode/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name    = "posix_mode"
  gem.version = GodObject::PosixMode::VERSION.dup
  gem.authors = ["Oliver Feldt", "Alexander E. Fischer", "Axel Sorge", "Andreas Wurm"]
  gem.email   = ["of@godobject.net", "aef@godobject.net", "as@godobject.net", "aw@godobject.net"]
  gem.description = <<-DESCRIPTION
PosixMode is a Ruby library providing an object representation of the common
POSIX file system permission bit sets called modes.

It can handle the generic read, write and execute permissions, as well as the
setuid, setgid and sticky flags. Modes can be read from file system objects,
parsed from typical string representations or simply defined by their numeric
representation. They can then be manipulated through binary logic operators and
written back to file system objects.
  DESCRIPTION
  gem.summary  = "Representation and manipulation of basic POSIX file system permissions in Ruby."
  gem.homepage = "https://www.godobject.net/"
  gem.license  = "ISC"
  gem.has_rdoc = "yard"
  gem.extra_rdoc_files  = ["HISTORY.md", "LICENSE.md"]
  gem.rubyforge_project = nil

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = '>= 1.9.3'

  gem.add_dependency('bit_set', '0.1.0')

  gem.add_development_dependency('rake')
  gem.add_development_dependency('bundler')
  gem.add_development_dependency('rspec', '~> 2.14.1')
  gem.add_development_dependency('simplecov')
  gem.add_development_dependency('pry')
  gem.add_development_dependency('yard')

  gem.cert_chain = "#{ENV['GEM_CERT_CHAIN']}".split(':')
  gem.signing_key = ENV['GEM_SIGNING_KEY']
end
