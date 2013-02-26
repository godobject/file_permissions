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

      describe ".parse" do

        context "given an octal representation" do
          it "should return an empty set if a 0 is given" do
            SpecialMode.parse('0').should eql SpecialMode.new(Set[])
          end

          it "should return a set including the sticky token if a 1 is given" do
            SpecialMode.parse('1').should eql SpecialMode.new(Set[:sticky])
          end

          it "should return a set including the setgid token if a 2 is given" do
            SpecialMode.parse('2').should eql SpecialMode.new(Set[:setgid])
          end

          it "should return a set including the setgid and sticky tokens if a 3 is given" do
            SpecialMode.parse('3').should eql SpecialMode.new(Set[:setgid, :sticky])
          end

          it "should return a set including the setuid token if a 4 is given" do
            SpecialMode.parse('4').should eql SpecialMode.new(Set[:setuid])
          end

          it "should return a set including the setuid and sticky tokens if a 5 is given" do
            SpecialMode.parse('5').should eql SpecialMode.new(Set[:setuid, :sticky])
          end

          it "should return a set including the setuid and setgid tokens if a 6 is given" do
            SpecialMode.parse('6').should eql SpecialMode.new(Set[:setuid, :setgid])
          end

          it "should return a set including the setuid, setgid and sticky tokens if a 7 is given" do
            SpecialMode.parse('7').should eql SpecialMode.new(Set[:setuid, :setgid, :sticky])
          end

          it "should raise an exception if 8 is given" do
            expect {
              SpecialMode.parse('8')
            }.to raise_error(ParserError, 'Invalid format')
          end
        end

        context "representation in symbolic mode" do
          it "should complain about a short representation" do
            expect {
              SpecialMode.parse('st')
            }.to raise_error(ParserError, 'Invalid format')
          end

          it "should complain about invalid symbols" do
            expect {
              SpecialMode.parse('s-a')
            }.to raise_error(ParserError, 'Invalid format')
          end

          it "should complain about invalid order" do
            expect {
              SpecialMode.parse('tss')
            }.to raise_error(ParserError, 'Invalid format')
          end

          it "should parse the setuid symbol" do
            result = SpecialMode.parse('s--')
            result.should eql SpecialMode.new(Set[:setuid])
          end

          it "should parse the setgid symbol" do
            result = SpecialMode.parse('-s-')
            result.should eql SpecialMode.new(Set[:setgid])
          end

          it "should parse the sticky symbol" do
            result = SpecialMode.parse('--t')
            result.should eql SpecialMode.new(Set[:sticky])
          end
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
          full_mode.inspect.should == "#<#{subject.class}: \"sst\">"
          setuid_setgid_mode.inspect.should == "#<#{subject.class}: \"ss-\">"
          setuid_sticky_mode.inspect.should == "#<#{subject.class}: \"s-t\">"
          setgid_sticky_mode.inspect.should == "#<#{subject.class}: \"-st\">"
          setuid_mode.inspect.should == "#<#{subject.class}: \"s--\">"
          setgid_mode.inspect.should == "#<#{subject.class}: \"-s-\">"
          sticky_mode.inspect.should == "#<#{subject.class}: \"--t\">"
          empty_mode.inspect.should == "#<#{subject.class}: \"---\">"
        end
      end

      describe "#to_s" do
        it "should represent attributes as string" do
          full_mode.to_s(:long).should == "sst"
          setuid_setgid_mode.to_s(:long).should == "ss-"
          setuid_sticky_mode.to_s(:long).should == "s-t"
          setgid_sticky_mode.to_s(:long).should == "-st"
          setuid_mode.to_s(:long).should  == "s--"
          setgid_mode.to_s(:long).should  == "-s-"
          sticky_mode.to_s(:long).should  == "--t"
          empty_mode.to_s(:long).should  == "---"
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
