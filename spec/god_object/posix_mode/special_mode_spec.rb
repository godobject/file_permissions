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

module GodObject
  module PosixMode

    describe SpecialMode do

      describe ".build" do
        it "should return the same object if a SpecialMode is given" do
          existing_mode = SpecialMode.new(5)

          mode = SpecialMode.build(existing_mode)

          expect(mode).to equal existing_mode
        end

        it "should create a new instance through parsing if given a String" do
          argument = 'r-x'

          expect(SpecialMode).to receive(:parse).once.with(argument)

          SpecialMode.build(argument)
        end

        it "should create a new instance if given something else" do
          argument = 4

          expect(SpecialMode).to receive(:new).once.with(argument)

          SpecialMode.build(argument)
        end
      end

      describe ".parse" do

        context "given an octal representation" do
          it "should return an empty set if a 0 is given" do
            expect(SpecialMode.parse('0')).to eql SpecialMode.new(Set[])
          end

          it "should return a set including the sticky token if a 1 is given" do
            expect(SpecialMode.parse('1')).to eql SpecialMode.new(Set[:sticky])
          end

          it "should return a set including the setgid token if a 2 is given" do
            expect(SpecialMode.parse('2')).to eql SpecialMode.new(Set[:setgid])
          end

          it "should return a set including the setgid and sticky tokens if a 3 is given" do
            expect(SpecialMode.parse('3')).to eql SpecialMode.new(Set[:setgid, :sticky])
          end

          it "should return a set including the setuid token if a 4 is given" do
            expect(SpecialMode.parse('4')).to eql SpecialMode.new(Set[:setuid])
          end

          it "should return a set including the setuid and sticky tokens if a 5 is given" do
            expect(SpecialMode.parse('5')).to eql SpecialMode.new(Set[:setuid, :sticky])
          end

          it "should return a set including the setuid and setgid tokens if a 6 is given" do
            expect(SpecialMode.parse('6')).to eql SpecialMode.new(Set[:setuid, :setgid])
          end

          it "should return a set including the setuid, setgid and sticky tokens if a 7 is given" do
            expect(SpecialMode.parse('7')).to eql SpecialMode.new(Set[:setuid, :setgid, :sticky])
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
            expect(result).to eql SpecialMode.new(Set[:setuid])
          end

          it "should parse the setgid symbol" do
            result = SpecialMode.parse('-s-')
            expect(result).to eql SpecialMode.new(Set[:setgid])
          end

          it "should parse the sticky symbol" do
            result = SpecialMode.parse('--t')
            expect(result).to eql SpecialMode.new(Set[:sticky])
          end
        end
      end

      describe ".new" do
        it "should handle no parameters" do
          mode = SpecialMode.new
          expect(mode).to be_a(SpecialMode)
          expect(mode.setuid?).to eql false
          expect(mode.setgid?).to eql false
          expect(mode.sticky?).to eql false
          expect(mode.to_i).to eql 0
          expect(mode.to_s).to eql "---"
          attributes = { setuid: false, setgid: false, sticky: false }
          expect(mode.state).to eql attributes
        end

        it "should handle a Set" do
          mode = SpecialMode.new(Set[:setuid, :sticky])

          expect(mode.state).to eql(setuid: true, setgid: false, sticky: true)
          expect(mode.setuid?).to eql true
          expect(mode.setgid?).to eql false
          expect(mode.sticky?).to eql true
        end

        it "should handle an array of mode components" do
          mode = SpecialMode.new(:setuid, :setgid, :sticky)
          attributes = { setuid: true, setgid: true, sticky: true }

          expect(mode.state).to eql attributes
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
          expect(empty_mode).to eq(empty_mode)
        end

        it "should be false if setuid attributes differ" do
          expect(setuid_sticky_mode).not_to eq(sticky_mode)
        end

        it "should be false if setgid attributes differ" do
          expect(setgid_sticky_mode).not_to eq(sticky_mode)
        end

        it "should be false if sticky attributes differ" do
          expect(setgid_sticky_mode).not_to eq(setgid_mode)
        end

        it "should be true if compared to a SpecialMode with same attributes" do
          expect(empty_mode).to eq(SpecialMode.new)
        end

        it "should be true if compared to an ACL-like with the same entries?" do
          other = OpenStruct.new(
            to_i: 6, configuration: OpenStruct.new(digits: [:setuid, :setgid, :sticky])
          )

          expect(setuid_setgid_mode).to eq(other)
        end
      end

      describe "#eql?" do
        it "should be true if compare to itself" do
          expect(SpecialMode.new).to eql SpecialMode.new
        end

        it "should be false if attributes are the same but class differs" do
          other = OpenStruct.new(attribute: { setuid: false, setgid: false, sticky: false })
          expect(SpecialMode.new).not_to eql other
        end
      end

      describe "#<=>" do
        it "should return -1 if the compared SpecialMode has a higher octal representation" do
          expect(setgid_mode <=> setuid_mode).to eql -1
        end

        it "should return 1 if the compared SpecialMode has a lower octal representation" do
          expect(setuid_mode <=> setgid_mode).to eql 1
        end

        it "should return 0 if the compared SpecialMode has an equal octal representation" do
          expect(sticky_mode <=> sticky_mode).to eql 0
        end

        it "should return nil if the compared object is incompatible" do
          expect(setgid_mode <=> :something).to eql nil
        end
      end

      describe "#inspect" do
        it "should give a decent string representation for debugging" do
          expect(full_mode.inspect).to eq("#<#{subject.class}: \"sst\">")
          expect(setuid_setgid_mode.inspect).to eq("#<#{subject.class}: \"ss-\">")
          expect(setuid_sticky_mode.inspect).to eq("#<#{subject.class}: \"s-t\">")
          expect(setgid_sticky_mode.inspect).to eq("#<#{subject.class}: \"-st\">")
          expect(setuid_mode.inspect).to eq("#<#{subject.class}: \"s--\">")
          expect(setgid_mode.inspect).to eq("#<#{subject.class}: \"-s-\">")
          expect(sticky_mode.inspect).to eq("#<#{subject.class}: \"--t\">")
          expect(empty_mode.inspect).to eq("#<#{subject.class}: \"---\">")
        end
      end

      describe "#to_s" do
        it "should represent attributes as string" do
          expect(full_mode.to_s(:long)).to eq("sst")
          expect(setuid_setgid_mode.to_s(:long)).to eq("ss-")
          expect(setuid_sticky_mode.to_s(:long)).to eq("s-t")
          expect(setgid_sticky_mode.to_s(:long)).to eq("-st")
          expect(setuid_mode.to_s(:long)).to  eq("s--")
          expect(setgid_mode.to_s(:long)).to  eq("-s-")
          expect(sticky_mode.to_s(:long)).to  eq("--t")
          expect(empty_mode.to_s(:long)).to  eq("---")
        end
      end

      describe "#to_i" do
        it "should represent no attributes in octal" do
          expect(empty_mode.to_i).to eql 0
        end

        it "should represent sticky attribute in octal" do
          expect(sticky_mode.to_i).to eql 1
        end

        it "should represent setgid attribute in octal" do
          expect(setgid_mode.to_i).to eql 2
        end

        it "should represent sticky and setgid attributes in octal" do
          expect(setgid_sticky_mode.to_i).to eql 3
        end

        it "should represent setuid attribute in octal" do
          expect(setuid_mode.to_i).to eql 4
        end

        it "should represent setuid and sticky attributes in octal" do
          expect(setuid_sticky_mode.to_i).to eql 5
        end

        it "should represent setuid and setgid attributes in octal" do
          expect(setuid_setgid_mode.to_i).to eql 6
        end

        it "should represent setuid, setgid and sticky attributes in octal" do
          expect(full_mode.to_i).to eql 7
        end
      end    
      
      describe "#setuid?" do
        it "should be true if setuid attribute is set" do
          expect(setuid_mode.setuid?).to eql true
        end

        it "should be false if setuid attribute is not set" do
          expect(setgid_sticky_mode.setuid?).to eql false
        end
      end

      describe "#setgid?" do
        it "should be true if setgid attribute is set" do
          expect(setgid_sticky_mode.setgid?).to eql true
        end

        it "should be false if setgid attribute is not set" do
          expect(setuid_sticky_mode.setgid?).to eql false
        end
      end    
      
      describe "#sticky?" do
        it "should be true if sticky attribute is set" do
          expect(setuid_sticky_mode.sticky?).to eql true
        end

        it "should be false if sticky attribute is not set" do
          expect(empty_mode.sticky?).to eql false
        end
      end

    describe "#invert" do
      it "should create a new SpecialMode with all digits inverted" do
        result = setuid_sticky_mode.invert

        expect(result).not_to equal setuid_sticky_mode
        expect(result).to eql setgid_mode
      end
    end

    describe "#-" do
      it "should create a new SpecialMode from the first operand without the digits of the second operand" do
        result = full_mode - setgid_mode

        expect(result).not_to equal full_mode
        expect(result).not_to equal setgid_mode
        expect(result).to eql setuid_sticky_mode
      end
    end

    [:intersection, :&].each do |method_name|
      describe "##{method_name}" do
        it "should create a new SpecialMode with only those digits enabled that are enabled in both operands" do
          result = setuid_setgid_mode.public_send(method_name, setgid_sticky_mode)

          expect(result).not_to equal setuid_setgid_mode
          expect(result).not_to equal setgid_sticky_mode
          expect(result).to eql setgid_mode
        end
      end
    end

    [:union, :|, :+].each do |method_name|
      describe "##{method_name}" do
        it "should create a new SpecialMode with all enabled digits of both operands" do
          result = setuid_mode.public_send(method_name, setgid_mode)

          expect(result).not_to equal setuid_mode
          expect(result).not_to equal setgid_mode
          expect(result).to eql setuid_setgid_mode
        end
      end
    end

    [:symmetric_difference, :^].each do |method_name|
      describe "##{method_name}" do
        it "should create a new SpecialMode with only those digits enabled that are enabled in only one operand" do
          result = full_mode.public_send(method_name, sticky_mode)

          expect(result).not_to equal full_mode
          expect(result).not_to equal sticky_mode
          expect(result).to eql setuid_setgid_mode
        end
      end
    end
      
    end
  end
end
