# encoding: UTF-8
=begin
Copyright GodObject Team <dev@godobject.net>, 2012-2016

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

require 'spec_helper'

module GodObject
  module PosixMode

    describe ComplexMode do

      describe ".build" do
        it "should return the same object if a ComplexMode is given" do
          existing_mode = ComplexMode.new(5)

          mode = ComplexMode.build(existing_mode)

          expect(mode).to equal existing_mode
        end

        it "should create a new instance if given something else" do
          argument = [:user_read, :user_write, :group_read, :other_execute, :sticky]

          expect(ComplexMode).to receive(:new).once.with(argument)

          ComplexMode.build(argument)
        end
      end

      describe ".new" do
        it "should handle an octal representation" do
          complex_mode = ComplexMode.new(00610)
          expect(complex_mode.user).to eql Mode.parse('rw')
          expect(complex_mode.group).to eql Mode.parse('x')
        end

        it "should handle a list of mode components" do
          complex_mode = ComplexMode.new(
            :user_read, :user_write, :user_execute, :group_read, :group_execute, :other_execute, :setgid, :sticky)

          expect(complex_mode.user).to eql Mode.parse('rwx')
          expect(complex_mode.group).to eql Mode.parse('rx')
          expect(complex_mode.other).to eql Mode.parse('x')
          expect(complex_mode.special).to eql SpecialMode.parse('-st')
        end

        it "should handle a Set of mode components" do
           mode = ComplexMode.new(Set[:user_read, :group_read, :group_execute, :setuid, :sticky])

           expect(mode.user.read?).to    eql true
           expect(mode.user.write?).to   eql false
           expect(mode.user.execute?).to eql false

           expect(mode.group.read?).to    eql true
           expect(mode.group.write?).to   eql false
           expect(mode.group.execute?).to eql true

           expect(mode.other.read?).to    eql false
           expect(mode.other.write?).to   eql false
           expect(mode.other.execute?).to eql false

           expect(mode.special.setuid?).to eql true
           expect(mode.special.setgid?).to eql false
           expect(mode.special.sticky?).to eql true
         end

        it "should complain about invalid input" do
          expect {
            ComplexMode.new(:wrong, :user_execute)
          }.to raise_error(ArgumentError)
        end
      end  

      describe ".from_file" do
        before(:each) do
          @test_directory = Pathname.new(Dir.mktmpdir('posix_mode_spec'))
        end

        after(:each) do
          @test_directory.rmtree
        end

        it "should create a complex mode from file" do
          test_file = (@test_directory + 'test_file')
          FileUtils.touch(test_file)
          test_file.chmod(05641)

          complex_mode = ComplexMode.from_file(test_file)
          expect(complex_mode.to_i).to eql 05641
        end

        it "should create a complex mode from file given as string" do
          test_file = (@test_directory + 'test_file')
          FileUtils.touch(test_file)
          test_file.chmod(05641)

          complex_mode = ComplexMode.from_file(test_file.to_s)
          expect(complex_mode.to_i).to eql 05641
        end

        it "should create a complex mode from the resolved symlink" do
          test_file = (@test_directory + 'test_file')
          FileUtils.touch(test_file)
          test_file.chmod(05641)

          test_link = (@test_directory + 'test_link')
          test_link.make_symlink(test_file)

          complex_mode = ComplexMode.from_file(test_link)
          expect(complex_mode.to_i).to eql 05641
        end

        it "should create a complex mode from the symlink itself if in 'target symlinks' mode" do
          test_file = (@test_directory + 'test_file')
          FileUtils.touch(test_file)
          test_file.chmod(05641)

          test_link = (@test_directory + 'test_link')
          test_link.make_symlink(test_file)

          complex_mode = ComplexMode.from_file(test_link, :target_symlinks)
          expect(complex_mode.to_i).to eql 00777
        end

        it "should complain about an invalid symlink handling" do
          test_file = (@test_directory + 'test_file')
          FileUtils.touch(test_file)

          expect {
            ComplexMode.from_file(test_file, :invalid)
          }.to raise_error(ArgumentError, "Invalid symlink handling: :invalid")
        end
      end

      describe "#user" do
        it "should return return the user's attributes as mode if setuid is set" do
          complex_mode = ComplexMode.new(07710)
          expect(complex_mode.user).to eql Mode.parse('rwx')
        end

        it "should return return the user's attributes as mode if setuid is unset" do
          complex_mode = ComplexMode.new(00510)
          expect(complex_mode.user).to eql Mode.parse('rx')
        end
      end  

      describe "#group" do
        it "should return return the group's attributes as mode if setgid is set" do
          complex_mode = ComplexMode.new(07770)
          expect(complex_mode.group).to eql Mode.parse('rwx')
        end

        it "should return return the group's attributes as mode if setgid is unset" do
          complex_mode = ComplexMode.new(00530)
          expect(complex_mode.group).to eql Mode.parse('wx')
        end
      end

      describe "#assign_to_file" do
        before(:each) do
          @test_directory = Pathname.new(Dir.mktmpdir('posix_mode_spec'))
        end

        after(:each) do
          @test_directory.rmtree
        end

        it "should assign a complex mode to file" do
          test_file = (@test_directory + 'test_file')
          FileUtils.touch(test_file)

          complex_mode = ComplexMode.new(05641)
          complex_mode.assign_to_file(test_file)

          expect(test_file.stat.mode & 0b111_111_111_111).to eql 05641
        end

        it "should assign a complex mode to file" do
          test_file = (@test_directory + 'test_file')
          FileUtils.touch(test_file)

          complex_mode = ComplexMode.new(05641)
          complex_mode.assign_to_file(test_file.to_s)

          expect(test_file.stat.mode & 0b111_111_111_111).to eql 05641
        end

        it "should assign a complex mode to the resolved symlink" do
          test_file = (@test_directory + 'test_file')
          FileUtils.touch(test_file)

          test_link = (@test_directory + 'test_link')
          test_link.make_symlink(test_file)

          complex_mode = ComplexMode.new(05641)
          complex_mode.assign_to_file(test_link)

          expect(test_file.stat.mode & 0b111_111_111_111).to eql 05641
        end

        it "should complain about missing lchmod function in 'target symlinks' mode" do
          test_file = (@test_directory + 'test_file')
          FileUtils.touch(test_file)

          test_link = (@test_directory + 'test_link')
          test_link.make_symlink(test_file)

          complex_mode = ComplexMode.new(05641)

          expect {
            complex_mode.assign_to_file(test_link, :target_symlinks)
          }.to raise_error(NotImplementedError, "lchmod function is not available in current OS or Ruby environment")
        end

        it "should assign a complex mode to the symlink itself in 'target symlinks' mode" do
          pending "This test is intended for systems where there is a lchmod function. No idea which system that may be. Have fun."

          test_file = (@test_directory + 'test_file')
          FileUtils.touch(test_file)

          test_link = (@test_directory + 'test_link')
          test_link.make_symlink(test_file)

          complex_mode = ComplexMode.new(05641)
          complex_mode.assign_to_file(test_link, :target_symlinks)

          expect(test_file.stat.mode & 0b111_111_111_111).to eql 05641
        end

        it "should complain about an invalid symlink handling" do
          test_file = (@test_directory + 'test_file')
          FileUtils.touch(test_file)

          complex_mode = ComplexMode.new(05641)

          expect {
            complex_mode.assign_to_file(test_file, :invalid)
          }.to raise_error(ArgumentError, "Invalid symlink handling: :invalid")
        end
      end

      describe "#inspect" do
        it "should represent the user, group and other read and write flags" do
          complex_mode = ComplexMode.new(00765)
          expect(complex_mode.inspect).to eql '#<GodObject::PosixMode::ComplexMode: "rwxrw-r-x">'
        end

        it "should represent the setuid flag if user execute flag is set" do
          complex_mode = ComplexMode.new(04715)
          expect(complex_mode.inspect).to eql '#<GodObject::PosixMode::ComplexMode: "rws--xr-x">'
        end

        it "should represent the setuid flag if user execute flag is unset" do
          complex_mode = ComplexMode.new(04615)
          expect(complex_mode.inspect).to eql '#<GodObject::PosixMode::ComplexMode: "rwS--xr-x">'
        end

        it "should represent the setgid flag if group execute flag is set" do
          complex_mode = ComplexMode.new(02615)
          expect(complex_mode.inspect).to eql '#<GodObject::PosixMode::ComplexMode: "rw---sr-x">'
        end

        it "should represent the setgid flag if group execute flag is unset" do
          complex_mode = ComplexMode.new(02605)
          expect(complex_mode.inspect).to eql '#<GodObject::PosixMode::ComplexMode: "rw---Sr-x">'
        end

        it "should represent the sticky flag if other execute flag is set" do
          complex_mode = ComplexMode.new(01435)
          expect(complex_mode.inspect).to eql '#<GodObject::PosixMode::ComplexMode: "r---wxr-t">'
        end

        it "should represent the sticky flag if other execute flag is unset" do
          complex_mode = ComplexMode.new(07004)
          expect(complex_mode.inspect).to eql '#<GodObject::PosixMode::ComplexMode: "--S--Sr-T">'
        end        
      end

      describe "#inspect" do
        it "should give a decent string representation for debugging" do
          complex_mode = ComplexMode.new(07004)
          expect(complex_mode.inspect).to eql '#<GodObject::PosixMode::ComplexMode: "--S--Sr-T">'
        end
      end
        
      describe "#to_s" do
        it "should represent the user, group and other read and write flags" do
          complex_mode = ComplexMode.new(00765)
          expect(complex_mode.to_s).to eql 'rwxrw-r-x'
        end

        it "should represent the setuid flag if user execute flag is set" do
          complex_mode = ComplexMode.new(04715)
          expect(complex_mode.to_s).to eql 'rws--xr-x'
        end

        it "should represent the setuid flag if user execute flag is unset" do
          complex_mode = ComplexMode.new(04615)
          expect(complex_mode.to_s).to eql 'rwS--xr-x'
        end

        it "should represent the setgid flag if group execute flag is set" do
          complex_mode = ComplexMode.new(02615)
          expect(complex_mode.to_s).to eql 'rw---sr-x'
        end

        it "should represent the setgid flag if group execute flag is unset" do
          complex_mode = ComplexMode.new(02605)
          expect(complex_mode.to_s).to eql 'rw---Sr-x'
        end

        it "should represent the sticky flag if other execute flag is set" do
          complex_mode = ComplexMode.new(01435)
          expect(complex_mode.to_s).to eql 'r---wxr-t'
        end

        it "should represent the sticky flag if other execute flag is unset" do
          complex_mode = ComplexMode.new(07004)
          expect(complex_mode.to_s).to eql '--S--Sr-T'
        end
      end

      describe "#to_i" do
        it "should return the correct octal representation" do
          complex_mode = ComplexMode.new(02615)

          expect(complex_mode.to_i).to eql 02615
        end
      end
      
    end

  end
end
