require 'spec_helper'

module GodObject
  module PosixMode
    describe Mode do
      describe ".parse" do

        context "given an octal representation" do
          it "should return an empty set if a 0 is given" do
            Mode.parse('0').should eql Mode.new(Set[])
            binding.pry
          end

          it "should return a set including the execute token if a 1 is given" do
            Mode.parse('1').should eql Mode.new(Set[:execute])
          end

          it "should return a set including the write token if a 2 is given" do
            Mode.parse('2').should eql Mode.new(Set[:write])
          end

          it "should return a set including the write and execute tokens if a 3 is given" do
            Mode.parse('3').should eql Mode.new(Set[:write, :execute])
          end

          it "should return a set including the read token if a 4 is given" do
            Mode.parse('4').should eql Mode.new(Set[:read])
          end

          it "should return a set including the read and execute tokens if a 5 is given" do
            Mode.parse('5').should eql Mode.new(Set[:read, :execute])
          end

          it "should return a set including the read and write tokens if a 6 is given" do
            Mode.parse('6').should eql Mode.new(Set[:read, :write])
          end

          it "should return a set including the read, write and execute tokens if a 7 is given" do
            Mode.parse('7').should eql Mode.new(Set[:read, :write, :execute])
          end

          it "should raise an exception if 8 is given" do
            expect {
              Mode.parse('8')
            }.to raise_error(ParserError, 'Invalid format')
          end
        end

        context "representation in symbolic mode" do
        it "should complain about duplicate read symbols" do
            expect {
              Mode.parse('r-r')
            }.to raise_error(ParserError, 'Duplicate digit in: "r-r"')
          end

          it "should complain about duplicate write symbols" do
            expect {
              Mode.parse('www')
            }.to raise_error(ParserError, 'Duplicate digit in: "www"')
          end

          it "should complain about duplicate execute symbols" do
            expect {
              Mode.parse('xx-')
            }.to raise_error(ParserError, 'Duplicate digit in: "xx-"')
          end

          it "should not complain about duplicate null symbols" do
            expect {
              Mode.parse('-r-')
            }.not_to raise_error(ParserError)
          end

          it "should parse the read symbol" do
            result = Mode.parse('r')
            result.should eql Mode.new(Set[:read])
          end

          it "should parse the write symbol" do
            result = Mode.parse('w')
            result.should eql Mode.new(Set[:write])
          end

          it "should parse the execute symbol" do
            result = Mode.parse('x')
            result.should eql Mode.new(Set[:execute])
          end
        end
      end

      describe ".new" do
        it "should handle no parameters" do
          mode = Mode.new
          mode.should be_a(PosixACL::Mode)
          mode.read?.should eql false
          mode.write?.should eql false
          mode.execute?.should eql false
          mode.to_i.should eql 0
          mode.to_s.should eql "---"
          mode.to_s(:short).should eql "-"
          attributes = { read: false, write: false, execute: false }
          mode.state.should eql attributes
        end
        
        it "should handle a string representation" do
          mode = Mode.parse('rwx')

          mode.state.should eql(read: true, write: true, execute: true)
          mode.read?.should eql true
          mode.write?.should eql true
          mode.execute?.should eql true
        end
        
        it "should handle an array of mode components" do
          mode = Mode.new([:read, :write, :execute])
          attributes = { read: true, write: true, execute: true }

          mode.state.should eql attributes
        end
      end

      let(:empty_mode) { Mode.parse('---') }
      let(:r_mode)     { Mode.parse('r--') }
      let(:w_mode)     { Mode.parse('-w-') }
      let(:rw_mode)    { Mode.parse('rw-') }
      let(:x_mode)     { Mode.parse('--x') }
      let(:rx_mode)    { Mode.parse('r-x') }
      let(:wx_mode)    { Mode.parse('-wx') }
      let(:rwx_mode)   { Mode.parse('rwx') }

      describe "#==" do
        it "should be true if compare to itself" do
          empty_mode.should == empty_mode
        end

        it "should be false if read attributes differ" do
          rx_mode.should_not == x_mode
        end

        it "should be false if write attributes differ" do
          wx_mode.should_not == x_mode
        end

        it "should be false if execute attributes differ" do
          wx_mode.should_not == w_mode
        end

        it "should be true if compared to a Mode with same attributes" do
          empty_mode.should == Mode.new
        end

        it "should be true if compared to an ACL-like with the same entries?" do
          other = OpenStruct.new(
            to_i: 6, configuration: OpenStruct.new(digits: [:read, :write, :execute])
          )

          rw_mode.should == other
        end
      end

      describe "#eql?" do
        it "should be true if compare to itself" do
          Mode.new.should eql Mode.new
        end

        it "should be false if attributes are the same but class differs" do
          other = OpenStruct.new(attribute: { read: false, write: false, execute: false })
          Mode.new.should_not eql other
        end
      end

      describe "#inspect" do
        it "should give a decent string representation for debugging" do
          rwx_mode.inspect.should == "#<#{subject.class}: \"rwx\">"
          rw_mode.inspect.should == "#<#{subject.class}: \"rw-\">"
          rx_mode.inspect.should == "#<#{subject.class}: \"r-x\">"
          wx_mode.inspect.should == "#<#{subject.class}: \"-wx\">"
          r_mode.inspect.should == "#<#{subject.class}: \"r--\">"
          w_mode.inspect.should == "#<#{subject.class}: \"-w-\">"
          x_mode.inspect.should == "#<#{subject.class}: \"--x\">"
          empty_mode.inspect.should == "#<#{subject.class}: \"---\">"
        end
      end

      describe "#to_s" do
        it "should represent attributes as string in long mode" do
          rwx_mode.to_s(:long).should == "rwx"
          rw_mode.to_s(:long).should == "rw-"
          rx_mode.to_s(:long).should == "r-x"
          wx_mode.to_s(:long).should == "-wx"
          r_mode.to_s(:long).should  == "r--"
          w_mode.to_s(:long).should  == "-w-"
          x_mode.to_s(:long).should  == "--x"
          empty_mode.to_s(:long).should  == "---"
        end

        it "should represent attributes as string in short mode" do
          rwx_mode.to_s(:short).should == "rwx"
          rw_mode.to_s(:short).should == "rw"
          rx_mode.to_s(:short).should == "rx"
          wx_mode.to_s(:short).should == "wx"
          r_mode.to_s(:short).should  == "r"
          w_mode.to_s(:short).should  == "w"
          x_mode.to_s(:short).should  == "x"
          empty_mode.to_s(:short).should  == "-"
        end
      end

      describe "#to_i" do
        it "should represent no attributes in octal" do
          empty_mode.to_i.should eql 0
        end

        it "should represent execute attribute in octal" do
          x_mode.to_i.should eql 1
        end

        it "should represent write attribute in octal" do
          w_mode.to_i.should eql 2
        end

        it "should represent execute and write attributes in octal" do
          wx_mode.to_i.should eql 3
        end

        it "should represent read attribute in octal" do
          r_mode.to_i.should eql 4 
        end

        it "should represent read and execute attributes in octal" do
          rx_mode.to_i.should eql 5
        end

        it "should represent read and write attributes in octal" do
          rw_mode.to_i.should eql 6
        end

        it "should represent read, write and execute attributes in octal" do
          rwx_mode.to_i.should eql 7
        end
      end    
      
      describe "#read?" do
        it "should be true if read attribute is set" do
          r_mode.read?.should eql true 
        end

        it "should be false if read attribute is not set" do
          wx_mode.read?.should eql false
        end
      end

      describe "#write?" do
        it "should be true if write attribute is set" do
          wx_mode.write?.should eql true 
        end

        it "should be false if write attribute is not set" do
          rx_mode.write?.should eql false
        end
      end    
      
      describe "#execute?" do
        it "should be true if execute attribute is set" do
          rx_mode.execute?.should eql true 
        end

        it "should be false if execute attribute is not set" do
          empty_mode.execute?.should eql false
        end
      end
    end
  end
end
