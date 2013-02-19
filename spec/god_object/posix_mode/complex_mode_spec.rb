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
        it "should handle mode components" do
          complex_mode = ComplexMode.new(00610)
          complex_mode.user.should eql Mode.parse('rw')
          complex_mode.group.should eql Mode.parse('x')
        end

        it "should complain about invalid input" do
        end
      end  

      describe ".from_file" do
        it "should create a complex mode from file" do
pending
          testfile = File.new('test')
          
          ComplexMode.from_file(testfile).to_s.should eql 'rwxrw-r--'
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
      
    end

  end
end
