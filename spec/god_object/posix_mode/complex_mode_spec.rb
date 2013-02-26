require 'spec_helper'

module GodObject
  module PosixMode

    describe ComplexMode do

      describe ".build" do
        it "should return the same object if a ComplexMode is given" do
          existing_mode = ComplexMode.new(5)

          mode = ComplexMode.build(existing_mode)

          mode.should equal existing_mode
        end

        it "should create a new instance if given something else" do
          argument = [:user_read, :user_write, :group_read, :other_execute, :sticky]

          ComplexMode.should_receive(:new).once.with(argument)

          ComplexMode.build(argument)
        end
      end

      describe ".new" do
        it "should handle an octal representation" do
          complex_mode = ComplexMode.new(00610)
          complex_mode.user.should eql Mode.parse('rw')
          complex_mode.group.should eql Mode.parse('x')
        end

        it "should handle a list of mode components" do
          complex_mode = ComplexMode.new([:user_read, :user_write, :user_execute, :group_read, :group_execute, :other_execute, :setgid, :sticky])

          complex_mode.user.should eql Mode.parse('rwx')
          complex_mode.group.should eql Mode.parse('rx')
          complex_mode.other.should eql Mode.parse('x')
          complex_mode.special.should eql SpecialMode.parse('-st')
        end

        it "should complain about invalid input" do
          expect {
            ComplexMode.new([:wrong, :user_execute])
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
          complex_mode.to_i.should eql 05641
        end

        it "should create a complex mode from file given as string" do
          test_file = (@test_directory + 'test_file')
          FileUtils.touch(test_file)
          test_file.chmod(05641)

          complex_mode = ComplexMode.from_file(test_file.to_s)
          complex_mode.to_i.should eql 05641
        end

        it "should create a complex mode from the resolved symlink" do
          test_file = (@test_directory + 'test_file')
          FileUtils.touch(test_file)
          test_file.chmod(05641)

          test_link = (@test_directory + 'test_link')
          test_link.make_link(test_file)

          complex_mode = ComplexMode.from_file(test_link)
          complex_mode.to_i.should eql 05641
        end

        it "should create a complex mode from the symlink itself if in 'target symlinks' mode" do
          pending "Find out why lchmod isn't implemented on Linux"

          test_file = (@test_directory + 'test_file')
          FileUtils.touch(test_file)
          test_file.chmod(05641)

          test_link = (@test_directory + 'test_link')
          test_link.make_link(test_file)
          test_link.lchmod(00411)

          complex_mode = ComplexMode.from_file(test_link, :target_symlinks)
          complex_mode.to_i.should eql 00411
        end
      end

      describe "#user" do
        it "should return return the user's attributes as mode if setuid is set" do
          complex_mode = ComplexMode.new(07710)
          complex_mode.user.should eql Mode.parse('rwx')
        end

        it "should return return the user's attributes as mode if setuid is unset" do
          complex_mode = ComplexMode.new(00510)
          complex_mode.user.should eql Mode.parse('rx')
        end
      end  

      describe "#group" do
        it "should return return the group's attributes as mode if setgid is set" do
          complex_mode = ComplexMode.new(07770)
          complex_mode.group.should eql Mode.parse('rwx')
        end

        it "should return return the group's attributes as mode if setgid is unset" do
          complex_mode = ComplexMode.new(00530)
          complex_mode.group.should eql Mode.parse('wx')
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

          (test_file.stat.mode & 0b111_111_111_111).should eql 05641
        end

        it "should assign a complex mode to file" do
          test_file = (@test_directory + 'test_file')
          FileUtils.touch(test_file)

          complex_mode = ComplexMode.new(05641)
          complex_mode.assign_to_file(test_file.to_s)

          (test_file.stat.mode & 0b111_111_111_111).should eql 05641
        end

        it "should assign a complex mode to the resolved symlink" do
          test_file = (@test_directory + 'test_file')
          FileUtils.touch(test_file)

          test_link = (@test_directory + 'test_link')
          test_link.make_link(test_file)

          complex_mode = ComplexMode.new(05641)
          complex_mode.assign_to_file(test_link)

          (test_file.stat.mode & 0b111_111_111_111).should eql 05641
        end

        it "should assign a complex mode to the symlink itself in 'target symlinks' mode" do
          pending "Find out why lchmod isn't implemented on Linux"

          test_file = (@test_directory + 'test_file')
          FileUtils.touch(test_file)

          test_link = (@test_directory + 'test_link')
          test_link.make_link(test_file)

          complex_mode = ComplexMode.new(05641)
          complex_mode.assign_to_file(test_link, :target_symlinks)

          (test_file.stat.mode & 0b111_111_111_111).should eql 05641
        end
      end

      describe "#inspect" do
        it "should represent the user, group and other read and write flags" do
          complex_mode = ComplexMode.new(00765)
          complex_mode.inspect.should eql '#<GodObject::PosixMode::ComplexMode: "rwxrw-r-x">'
        end

        it "should represent the setuid flag if user execute flag is set" do
          complex_mode = ComplexMode.new(04715)
          complex_mode.inspect.should eql '#<GodObject::PosixMode::ComplexMode: "rws--xr-x">'
        end

        it "should represent the setuid flag if user execute flag is unset" do
          complex_mode = ComplexMode.new(04615)
          complex_mode.inspect.should eql '#<GodObject::PosixMode::ComplexMode: "rwS--xr-x">'
        end

        it "should represent the setgid flag if group execute flag is set" do
          complex_mode = ComplexMode.new(02615)
          complex_mode.inspect.should eql '#<GodObject::PosixMode::ComplexMode: "rw---sr-x">'
        end

        it "should represent the setgid flag if group execute flag is unset" do
          complex_mode = ComplexMode.new(02605)
          complex_mode.inspect.should eql '#<GodObject::PosixMode::ComplexMode: "rw---Sr-x">'
        end

        it "should represent the sticky flag if other execute flag is set" do
          complex_mode = ComplexMode.new(01435)
          complex_mode.inspect.should eql '#<GodObject::PosixMode::ComplexMode: "r---wxr-t">'
        end

        it "should represent the sticky flag if other execute flag is unset" do
          complex_mode = ComplexMode.new(07004)
          complex_mode.inspect.should eql '#<GodObject::PosixMode::ComplexMode: "--S--Sr-T">'
        end        
      end
        
      describe "#to_s" do
        it "should represent the user, group and other read and write flags" do
          complex_mode = ComplexMode.new(00765)
          complex_mode.to_s.should eql 'rwxrw-r-x'
        end

        it "should represent the setuid flag if user execute flag is set" do
          complex_mode = ComplexMode.new(04715)
          complex_mode.to_s.should eql 'rws--xr-x'
        end

        it "should represent the setuid flag if user execute flag is unset" do
          complex_mode = ComplexMode.new(04615)
          complex_mode.to_s.should eql 'rwS--xr-x'
        end

        it "should represent the setgid flag if group execute flag is set" do
          complex_mode = ComplexMode.new(02615)
          complex_mode.to_s.should eql 'rw---sr-x'
        end

        it "should represent the setgid flag if group execute flag is unset" do
          complex_mode = ComplexMode.new(02605)
          complex_mode.to_s.should eql 'rw---Sr-x'
        end

        it "should represent the sticky flag if other execute flag is set" do
          complex_mode = ComplexMode.new(01435)
          complex_mode.to_s.should eql 'r---wxr-t'
        end

        it "should represent the sticky flag if other execute flag is unset" do
          complex_mode = ComplexMode.new(07004)
          complex_mode.to_s.should eql '--S--Sr-T'
        end
      end

      describe "#to_i" do
        it "should return the correct octal representation" do
          complex_mode = ComplexMode.new(02615)

          complex_mode.to_i.should eql 02615
        end
      end
      
    end

  end
end
