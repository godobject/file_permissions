# encoding: UTF-8
=begin
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
=end

module GodObject
  module FilePermissions

    describe Mode do
      describe ".build" do
        it "should return the same object if a Mode is given" do
          existing_mode = Mode.new(5)

          mode = Mode.build(existing_mode)

          expect(mode).to equal existing_mode
        end

        it "should create a new instance through parsing if given a String" do
          argument = 's-t'

          expect(Mode).to receive(:parse).once.with(argument)

          Mode.build(argument)
        end

        it "should create a new instance if given something else" do
          argument = 4

          expect(Mode).to receive(:new).once.with(argument)

          Mode.build(argument)
        end
      end

      describe ".parse" do
        context "given an octal representation" do
          it "should return an empty set if a 0 is given" do
            expect(Mode.parse('0')).to eql Mode.new(Set[])
          end

          it "should return a set including the execute token if a 1 is given" do
            expect(Mode.parse('1')).to eql Mode.new(Set[:execute])
          end

          it "should return a set including the write token if a 2 is given" do
            expect(Mode.parse('2')).to eql Mode.new(Set[:write])
          end

          it "should return a set including the write and execute tokens if a 3 is given" do
            expect(Mode.parse('3')).to eql Mode.new(Set[:write, :execute])
          end

          it "should return a set including the read token if a 4 is given" do
            expect(Mode.parse('4')).to eql Mode.new(Set[:read])
          end

          it "should return a set including the read and execute tokens if a 5 is given" do
            expect(Mode.parse('5')).to eql Mode.new(Set[:read, :execute])
          end

          it "should return a set including the read and write tokens if a 6 is given" do
            expect(Mode.parse('6')).to eql Mode.new(Set[:read, :write])
          end

          it "should return a set including the read, write and execute tokens if a 7 is given" do
            expect(Mode.parse('7')).to eql Mode.new(Set[:read, :write, :execute])
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

          it "should complain about invalid symbols" do
            expect {
              Mode.parse('r-a')
            }.to raise_error(ParserError, 'Invalid format')
          end

          it "should not complain about duplicate null symbols" do
            expect {
              Mode.parse('-r-')
            }.not_to raise_error
          end

          it "should parse the read symbol" do
            result = Mode.parse('r')
            expect(result).to eql Mode.new(Set[:read])
          end

          it "should parse the write symbol" do
            result = Mode.parse('w')
            expect(result).to eql Mode.new(Set[:write])
          end

          it "should parse the execute symbol" do
            result = Mode.parse('x')
            expect(result).to eql Mode.new(Set[:execute])
          end
        end
      end

      describe ".new" do
        it "should handle no parameters" do
          mode = Mode.new
          expect(mode).to be_a(Mode)
          expect(mode.read?).to eql false
          expect(mode.write?).to eql false
          expect(mode.execute?).to eql false
          expect(mode.to_i).to eql 0
          expect(mode.to_s).to eql "---"
          expect(mode.to_s(:short)).to eql "-"
          attributes = { read: false, write: false, execute: false }
          expect(mode.state).to eql attributes
        end
        
        it "should handle a Set" do
          mode = Mode.new(Set[:read, :execute])

          expect(mode.state).to eql(read: true, write: false, execute: true)
          expect(mode.read?).to eql true
          expect(mode.write?).to eql false
          expect(mode.execute?).to eql true
        end

        it "should handle an array of mode components" do
          mode = Mode.new(:read, :write, :execute)
          attributes = { read: true, write: true, execute: true }

          expect(mode.state).to eql attributes
        end
      end

      let(:empty_mode) { Mode.parse('---') }
      let(:x_mode)     { Mode.parse('--x') }
      let(:w_mode)     { Mode.parse('-w-') }
      let(:wx_mode)    { Mode.parse('-wx') }
      let(:r_mode)     { Mode.parse('r--') }
      let(:rx_mode)    { Mode.parse('r-x') }
      let(:rw_mode)    { Mode.parse('rw-') }
      let(:rwx_mode)   { Mode.parse('rwx') }

      describe "#==" do
        it "should be true if compare to itself" do
          expect(empty_mode).to eq(empty_mode)
        end

        it "should be false if read attributes differ" do
          expect(rx_mode).not_to eq(x_mode)
        end

        it "should be false if write attributes differ" do
          expect(wx_mode).not_to eq(x_mode)
        end

        it "should be false if execute attributes differ" do
          expect(wx_mode).not_to eq(w_mode)
        end

        it "should be true if compared to a Mode with same attributes" do
          expect(empty_mode).to eq(Mode.new)
        end

        it "should be true if compared to an ACL-like with the same entries?" do
          other = OpenStruct.new(
            to_i: 6, configuration: OpenStruct.new(digits: [:read, :write, :execute])
          )

          expect(rw_mode).to eq(other)
        end
      end

      describe "#eql?" do
        it "should be true if compare to itself" do
          expect(Mode.new).to eql Mode.new
        end

        it "should be false if attributes are the same but class differs" do
          other = OpenStruct.new(attribute: { read: false, write: false, execute: false })
          expect(Mode.new).not_to eql other
        end
      end

      describe "#<=>" do
        it "should return -1 if the compared Mode has a higher octal representation" do
          expect(w_mode <=> r_mode).to eql -1
        end

        it "should return 1 if the compared Mode has a lower octal representation" do
          expect(r_mode <=> w_mode).to eql 1
        end

        it "should return 0 if the compared Mode has an equal octal representation" do
          expect(x_mode <=> x_mode).to eql 0
        end

        it "should return nil if the compared object is incompatible" do
          expect(w_mode <=> :something).to eql nil
        end
      end

      describe "#inspect" do
        it "should give a decent string representation for debugging" do
          expect(rwx_mode.inspect).to eq("#<#{subject.class}: \"rwx\">")
          expect(rw_mode.inspect).to eq("#<#{subject.class}: \"rw-\">")
          expect(rx_mode.inspect).to eq("#<#{subject.class}: \"r-x\">")
          expect(wx_mode.inspect).to eq("#<#{subject.class}: \"-wx\">")
          expect(r_mode.inspect).to eq("#<#{subject.class}: \"r--\">")
          expect(w_mode.inspect).to eq("#<#{subject.class}: \"-w-\">")
          expect(x_mode.inspect).to eq("#<#{subject.class}: \"--x\">")
          expect(empty_mode.inspect).to eq("#<#{subject.class}: \"---\">")
        end
      end

      describe "#to_s" do
        it "should represent attributes as string in long mode" do
          expect(rwx_mode.to_s(:long)).to eq("rwx")
          expect(rw_mode.to_s(:long)).to eq("rw-")
          expect(rx_mode.to_s(:long)).to eq("r-x")
          expect(wx_mode.to_s(:long)).to eq("-wx")
          expect(r_mode.to_s(:long)).to  eq("r--")
          expect(w_mode.to_s(:long)).to  eq("-w-")
          expect(x_mode.to_s(:long)).to  eq("--x")
          expect(empty_mode.to_s(:long)).to  eq("---")
        end

        it "should represent attributes as string in short mode" do
          expect(rwx_mode.to_s(:short)).to eq("rwx")
          expect(rw_mode.to_s(:short)).to eq("rw")
          expect(rx_mode.to_s(:short)).to eq("rx")
          expect(wx_mode.to_s(:short)).to eq("wx")
          expect(r_mode.to_s(:short)).to  eq("r")
          expect(w_mode.to_s(:short)).to  eq("w")
          expect(x_mode.to_s(:short)).to  eq("x")
          expect(empty_mode.to_s(:short)).to  eq("-")
        end
      end

      describe "#to_i" do
        it "should represent no attributes in octal" do
          expect(empty_mode.to_i).to eql 0
        end

        it "should represent execute attribute in octal" do
          expect(x_mode.to_i).to eql 1
        end

        it "should represent write attribute in octal" do
          expect(w_mode.to_i).to eql 2
        end

        it "should represent execute and write attributes in octal" do
          expect(wx_mode.to_i).to eql 3
        end

        it "should represent read attribute in octal" do
          expect(r_mode.to_i).to eql 4 
        end

        it "should represent read and execute attributes in octal" do
          expect(rx_mode.to_i).to eql 5
        end

        it "should represent read and write attributes in octal" do
          expect(rw_mode.to_i).to eql 6
        end

        it "should represent read, write and execute attributes in octal" do
          expect(rwx_mode.to_i).to eql 7
        end
      end    
      
      describe "#read?" do
        it "should be true if read attribute is set" do
          expect(r_mode.read?).to eql true 
        end

        it "should be false if read attribute is not set" do
          expect(wx_mode.read?).to eql false
        end
      end

      describe "#write?" do
        it "should be true if write attribute is set" do
          expect(wx_mode.write?).to eql true 
        end

        it "should be false if write attribute is not set" do
          expect(rx_mode.write?).to eql false
        end
      end    
      
      describe "#execute?" do
        it "should be true if execute attribute is set" do
          expect(rx_mode.execute?).to eql true 
        end

        it "should be false if execute attribute is not set" do
          expect(empty_mode.execute?).to eql false
        end
      end

      describe "#invert" do
        it "should create a new Mode with all digits inverted" do
          result = rx_mode.invert

          expect(result).not_to equal rx_mode
          expect(result).to eql w_mode
        end
      end

      describe "#-" do
        it "should create a new Mode from the first operand without the digits of the second operand" do
          result = rwx_mode - w_mode

          expect(result).not_to equal rwx_mode
          expect(result).not_to equal w_mode
          expect(result).to eql rx_mode
        end
      end

      [:intersection, :&].each do |method_name|
        describe "##{method_name}" do
          it "should create a new Mode with only those digits enabled that are enabled in both operands" do
            result = rw_mode.public_send(method_name, wx_mode)

            expect(result).not_to equal rw_mode
            expect(result).not_to equal wx_mode
            expect(result).to eql w_mode
          end
        end
      end

      [:union, :|, :+].each do |method_name|
        describe "##{method_name}" do
          it "should create a new Mode with all enabled digits of both operands" do
            result = r_mode.public_send(method_name, w_mode)

            expect(result).not_to equal r_mode
            expect(result).not_to equal w_mode
            expect(result).to eql rw_mode
          end
        end
      end

      [:symmetric_difference, :^].each do |method_name|
        describe "##{method_name}" do
          it "should create a new Mode with only those digits enabled that are enabled in only one operand" do
            result = rwx_mode.public_send(method_name, x_mode)

            expect(result).not_to equal rwx_mode
            expect(result).not_to equal x_mode
            expect(result).to eql rw_mode
          end
        end
      end
    end

  end
end
