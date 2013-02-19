require 'spec_helper'

module GodObject
  module PosixMode

    describe SpecialMode do

      describe ".build" do
        it "should return the same object if a SpecialMode is given" do
          existing_mode = SpecialMode.new(5)

          mode = SpecialMode.build(existing_mode)

          mode.should equal existing_mode
        end

        it "should create a new instance if given something else" do
          argument = 4

          SpecialMode.should_receive(:new).once.with(argument)

          SpecialMode.build(argument)
        end
      end

      describe ".new" do
        it "should handle no parameters" do
          mode = SpecialMode.new
          mode.should be_a(SpecialMode)
          mode.setuid?.should eql false
          mode.setgid?.should eql false
          mode.sticky?.should eql false
          mode.to_i.should eql 0
          mode.to_s.should eql "---"
          attributes = { setuid: false, setgid: false, sticky: false }
          mode.state.should eql attributes
        end

        it "should handle an array of mode components" do
          mode = SpecialMode.new([:setuid, :setgid, :sticky])
          attributes = { setuid: true, setgid: true, sticky: true }

          mode.state.should eql attributes
        end
      end

      let(:empty_mode)         { SpecialMode.parse('---') }
      let(:sticky_mode)        { SpecialMode.parse('--t') }
      let(:setgid_mode)        { SpecialMode.parse('-s-') }
      let(:setgid_sticky_mode) { SpecialMode.parse('-st') }
      let(:setuid_mode)        { SpecialMode.parse('s--') }
      let(:setuid_sticky_mode) { SpecialMode.parse('s-t') }
      let(:setuid_setgid_mode) { SpecialMode.parse('ss-') }
      let(:full_mode)          { SpecialMode.parse('sst') }

      describe "#==" do
        it "should be true if compare to itself" do
          empty_mode.should == empty_mode
        end

        it "should be false if setuid attributes differ" do
          setuid_sticky_mode.should_not == sticky_mode
        end

        it "should be false if setgid attributes differ" do
          setgid_sticky_mode.should_not == sticky_mode
        end

        it "should be false if sticky attributes differ" do
          setgid_sticky_mode.should_not == setgid_mode
        end

        it "should be true if compared to a SpecialMode with same attributes" do
          empty_mode.should == SpecialMode.new
        end

        it "should be true if compared to an ACL-like with the same entries?" do
          other = OpenStruct.new(
            to_i: 6, configuration: OpenStruct.new(digits: [:setuid, :setgid, :sticky])
          )

          setuid_setgid_mode.should == other
        end
      end

      describe "#eql?" do
        it "should be true if compare to itself" do
          SpecialMode.new.should eql SpecialMode.new
        end

        it "should be false if attributes are the same but class differs" do
          other = OpenStruct.new(attribute: { setuid: false, setgid: false, sticky: false })
          SpecialMode.new.should_not eql other
        end
      end

      describe "#inspect" do
        it "should give a decent string representation for debugging" do
          full_mode.inspect.should == "#<#{subject.class}: \"rwx\">"
          setuid_setgid_mode.inspect.should == "#<#{subject.class}: \"rw-\">"
          setuid_sticky_mode.inspect.should == "#<#{subject.class}: \"r-x\">"
          setgid_sticky_mode.inspect.should == "#<#{subject.class}: \"-wx\">"
          setuid_mode.inspect.should == "#<#{subject.class}: \"r--\">"
          setgid_mode.inspect.should == "#<#{subject.class}: \"-w-\">"
          sticky_mode.inspect.should == "#<#{subject.class}: \"--x\">"
          empty_mode.inspect.should == "#<#{subject.class}: \"---\">"
        end
      end

      describe "#to_s" do
        it "should represent attributes as string in long mode" do
          full_mode.to_s(:long).should == "rwx"
          setuid_setgid_mode.to_s(:long).should == "rw-"
          setuid_sticky_mode.to_s(:long).should == "r-x"
          setgid_sticky_mode.to_s(:long).should == "-wx"
          setuid_mode.to_s(:long).should  == "r--"
          setgid_mode.to_s(:long).should  == "-w-"
          sticky_mode.to_s(:long).should  == "--x"
          empty_mode.to_s(:long).should  == "---"
        end

        it "should represent attributes as string in short mode" do
          full_mode.to_s(:short).should == "rwx"
          setuid_setgid_mode.to_s(:short).should == "rw"
          setuid_sticky_mode.to_s(:short).should == "rx"
          setgid_sticky_mode.to_s(:short).should == "wx"
          setuid_mode.to_s(:short).should  == "r"
          setgid_mode.to_s(:short).should  == "w"
          sticky_mode.to_s(:short).should  == "x"
          empty_mode.to_s(:short).should  == "-"
        end
      end

      describe "#to_i" do
        it "should represent no attributes in octal" do
          empty_mode.to_i.should eql 0
        end

        it "should represent sticky attribute in octal" do
          sticky_mode.to_i.should eql 1
        end

        it "should represent setgid attribute in octal" do
          setgid_mode.to_i.should eql 2
        end

        it "should represent sticky and setgid attributes in octal" do
          setgid_sticky_mode.to_i.should eql 3
        end

        it "should represent setuid attribute in octal" do
          setuid_mode.to_i.should eql 4
        end

        it "should represent setuid and sticky attributes in octal" do
          setuid_sticky_mode.to_i.should eql 5
        end

        it "should represent setuid and setgid attributes in octal" do
          setuid_setgid_mode.to_i.should eql 6
        end

        it "should represent setuid, setgid and sticky attributes in octal" do
          full_mode.to_i.should eql 7
        end
      end    
      
      describe "#setuid?" do
        it "should be true if setuid attribute is set" do
          setuid_mode.setuid?.should eql true
        end

        it "should be false if setuid attribute is not set" do
          setgid_sticky_mode.setuid?.should eql false
        end
      end

      describe "#setgid?" do
        it "should be true if setgid attribute is set" do
          setgid_sticky_mode.setgid?.should eql true
        end

        it "should be false if setgid attribute is not set" do
          setuid_sticky_mode.setgid?.should eql false
        end
      end    
      
      describe "#sticky?" do
        it "should be true if sticky attribute is set" do
          setuid_sticky_mode.sticky?.should eql true
        end

        it "should be false if sticky attribute is not set" do
          empty_mode.sticky?.should eql false
        end
      end
    end
  end
end
