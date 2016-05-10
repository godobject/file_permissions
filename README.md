FilePermissions
===============

[![Gem Version](https://badge.fury.io/rb/file_permissions.png)](https://badge.fury.io/rb/file_permissions)
[![Dependency Status](https://gemnasium.com/godobject/file_permissions.png)](https://gemnasium.com/godobject/file_permissions)
[![Code Climate](https://codeclimate.com/github/godobject/file_permissions.png)](https://codeclimate.com/github/godobject/file_permissions)
[![Build Status](https://secure.travis-ci.org/godobject/file_permissions.png)](https://secure.travis-ci.org/godobject/file_permissions)
[![Coverage Status](https://coveralls.io/repos/github/godobject/file_permissions/badge.svg?branch=master)](https://coveralls.io/github/godobject/file_permissions?branch=master)

* [Documentation][docs]
* [Project][project]

   [docs]:    http://rdoc.info/github/godobject/file_permissions/
   [project]: https://github.com/godobject/file_permissions/

Description
-----------

FilePermissions is a Ruby library providing an object representation of the
file permission bits in POSIX systems.

It can handle the generic read, write and execute permissions, as well as
the setuid, setgid and sticky flags. Permission sets can be read from file
system objects, parsed from typical string representations or simply
defined by their numeric representation. They can then be manipulated
through binary logic operators and written back to file system objects.

Features / Problems
-------------------

This project tries to conform to:

* [Semantic Versioning (2.0.0)][semver]
* [Ruby Packaging Standard (0.5-draft)][rps]
* [Ruby Style Guide][style]
* [Gem Packaging: Best Practices][gem]

   [semver]: http://semver.org/spec/v2.0.0.html
   [rps]:    http://chneukirchen.github.com/rps/
   [style]:  https://github.com/bbatsov/ruby-style-guide
   [gem]:    http://weblog.rubyonrails.org/2009/9/1/gem-packaging-best-practices

Additional facts:

* Written purely in Ruby.
* Documented with YARD.
* Automatically testable through RSpec.
* Intended to be used with Ruby 1.9.3 or higher.
* Cryptographically signed git tags.
* This library was developed as part of the
  [PosixACL](https://rubygems.org/gems/posix_acl) project.

Requirements
------------

* Ruby 1.9.3 or higher
* [bit_set](https://rubygems.org/gems/bit_set)

Installation
------------

On *nix systems you may need to prefix the command with `sudo` to get root
privileges.

### Gem

    gem install file_permissions

### Automated testing

Go into the root directory of the installed gem and run the following command
to fetch all development dependencies:

    bundle

Afterwards start the test runner:

    rake spec

If something goes wrong you should be notified through failing examples.

Usage
-----

This documentation defines the public interface of the software. The version
number of the software tracks changes to this public interface as described in
[Semantic Versioning][semver]. Do not use elements that are marked as private.
These elements are not guaranteed to exist in otherwise compatible future
versions. Should you really need some parts that are currently marked as
private, please contact us. We might be able to expose them as public
interface for your convenience.

This is still experimental software, even the public interface may change
substantially in future releases.

   [semver]: http://semver.org/spec/v2.0.0.html

### Ruby interface

#### Loading

In most cases you want to load the code by using the following command:

~~~~~ ruby
require 'file_permissions'
~~~~~

In a bundler Gemfile you should use the following:

~~~~~ ruby
gem 'file_permissions'
~~~~~

#### Namespace

This project is contained within a namespace to avoid name collisions with
other code. If you do not want to specifiy the namespace explicitly you can
include it into the current scope by executing the following statement:

~~~~~ ruby
include GodObject::FilePermissions
~~~~~

The following documentation assumes that you did include the namespace.

#### The ComplexMode

The complete regular permissions of a POSIX file system object are represented
by the ComplexMode. It aggregates three Mode objects which define the read,
write and execute permissions for the owner, the owning group and others
respectively. Additionally it holds an instance of the SpecialMode to define
the state of the setuid, setgid and sticky flags of the file system object.

A ComplexMode can be created from a typical octal mode representation:

~~~~~ ruby
ComplexMode.new(0644)
# => #<GodObject::FilePermissions::ComplexMode: "rw-r--r--">

ComplexMode.new(03644)
# => #<GodObject::FilePermissions::ComplexMode: "rw-r-Sr-T">
~~~~~

Or simply by a list of permission digits:

~~~~~ ruby
ComplexMode.new(:user_write, :group_execute, :other_read, :sticky)
# => #<GodObject::FilePermissions::ComplexMode: "-w---xr-T">
~~~~~

It can also be read from the file system like this:

~~~~~ ruby
mode = ComplexMode.from_file('/path/to/a/file')

# => #<GodObject::FilePermissions::ComplexMode: "rwsr-x---">
~~~~~

Note that it also accepts a Pathname object instead of a path String.

The ComplexMode object can now be used to access the permissions:

~~~~~ ruby
mode.user.execute?
# => true

mode.group.read?
# => true

mode.other.write?
# => false

mode.setuid?
# => true
~~~~~

Also you can modify the ComplexMode by replacing its aggregated Mode objects:

~~~~~ ruby
mode.other = Mode.new(:read, :execute)

mode
# => #<GodObject::FilePermissions::ComplexMode: "rwsr-xr-x">
~~~~~

~~~~~ ruby
mode.special = SpecialMode.new(:setuid, :setgid)

mode
# => #<GodObject::FilePermissions::ComplexMode: "rwsr-sr-x">
~~~~~

The ComplexMode can be again written to a file system object by issuing the
following:

~~~~~ ruby
mode.assign_to_file('/path/to/some/other/file')
~~~~~

Note that it also accepts a Pathname object instead of a path String.

#### Mode and SpecialMode

Both Mode and SpecialMode are intended to be parts of the ComplexMode.
Instances are immutable and can therefore only be defined during creation.

New instances can either be created by a list of permission digits:

~~~~~ ruby
Mode.new(:read, :write, :execute)
# => #<GodObject::FilePermissions::Mode: "rwx">
~~~~~

~~~~~ ruby
SpecialMode.new(:setuid, :setgid, :sticky)
# => #<GodObject::FilePermissions::SpecialMode: "sst">
~~~~~

Or be defined by their octal digit representation:

~~~~~ ruby
Mode.new(5)
# => #<GodObject::FilePermissions::Mode: "r-x">
~~~~~

~~~~~ ruby
SpecialMode.new(3)
# => #<GodObject::FilePermissions::SpecialMode: "-st">
~~~~~

Another way to create new instances is to parse a String representation:

~~~~~ ruby
regular_mode = Mode.parse('xr')
# => #<GodObject::FilePermissions::Mode: "r-x">
~~~~~

~~~~~ ruby
special_mode = SpecialMode.new('-st')
# => #<GodObject::FilePermissions::SpecialMode: "-st">
~~~~~

Note that instead of the Mode, when parsing a SpecialMode, the String
representation has to be in the correct order and including dashes for disabled
digits because the SpecialMode representation doesn't have unique character
representations for each permission digit.

Both Mode and SpecialMode can then be asked for the state of their digits:

~~~~~ ruby
regular_mode.read?
# => true
regular_mode.write?
# => false
regular_mode.execute?
# => true

regular_mode.state
# => {:read => true, :write => false, :execute => true}

regular_mode.enabled_digits
# => #<Set: {:read, :execute}>

regular_mode.disabled_digits
# => #<Set: {:write}>
~~~~~

~~~~~ ruby
special_mode.setuid?
# => false
special_mode.setgid?
# => true
special_mode.sticky?
# => true

special_mode.state
# => {:setuid => false, :setgid => true, :sticky => true}

special_mode.enabled_digits
# => #<Set: {:setgid, :sticky}>

special_mode.disabled_digits
# => #<Set: {:setuid}>
~~~~~

Development
-----------

### Bug reports and feature requests

Please use the [issue tracker][issues] on github.com to let us know about errors
or ideas for improvement of this software.

   [issues]: https://github.com/godobject/file_permissions/issues/

### Source code

#### Distribution

This software is developed in the source code management system Git. There are
several synchronized mirror repositories available:

* [GitHub][github] (located in California, USA)
    
    URI: https://github.com/godobject/file_permissions.git

* [GitLab][gitlab] (located in Illinois, USA)
    
    URI: https://gitlab.com/godobject/file_permissions.git

* [BitBucket][bitbucket] (located in California, USA)
    
    URI: https://bitbucket.org/godobject/file_permissions.git

* [Pikacode][pikacode] (located in France)

    URI: https://pikacode.com/godobject/file_permissions.git

   [github]:    https://github.com/godobject/file_permissions/
   [gitlab]:    https://gitlab.com/godobject/file_permissions/
   [bitbucket]: https://bitbucket.org/godobject/file_permissions/
   [pikacode]:  https://pikacode.com/godobject/file_permissions/

You can get the latest source code with the following command, while
exchanging the placeholder for one of the mirror URIs:

    git clone MIRROR_URI

#### Tags and cryptographic verification

The final commit before each released gem version will be marked by a tag
named like the version with a prefixed lower-case "v". Every tag will be signed
by Alexander E. Fischer's [OpenPGP public key][openpgp] which enables you to
verify your copy of the code cryptographically.

   [openpgp]: https://aef.name/crypto/aef-openpgp.asc

Add the key to your GnuPG keyring by the following command:

    gpg --import aef-openpgp.asc

This command will tell you if your code is of integrity and authentic:

    git tag --verify [TAG NAME]

#### Building gems

To package your state of the source code into a gem package use the following
command:

    rake build

The gem will be generated according to the .gemspec file in the project root
directory and will be placed into the pkg/ directory.

### Contribution

Help on making this software better is always very appreciated. If you want
your changes to be included in the official release, please clone the project
on github.com, create a named branch to commit, push your changes into it and
send a pull request afterwards.

Please make sure to write tests for your changes so that no one else will break
them when changing other things. Also notice that an inclusion of your changes
cannot be guaranteed before reviewing them.

The following people were involved in development:

* Oliver Feldt <of@godobject.net>
* Alexander E. Fischer <aef@godobject.net>
* Axel Sorge <as@godobject.net>
* Andreas Wurm <aw@godobject.net>

License
-------

Copyright GodObject Team <dev@godobject.net>, 2012-2016

This file is part of FilePermissions.

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
