require File.expand_path "../../teststrap", __FILE__

describe Gale::File do
  before :all do
    $window = Gosu::Window.new(10, 10, false)
  end

  context "class" do
    describe ".new" do
      it "accepts a block and auto-closes" do
        yielded = false

        described_class.new COP_RANGED_GAL do |file|
          file.should be_a described_class
          file.should_receive(:close)
          yielded = true
        end
        yielded.should be_true
      end

      it "fails if the file doesn't exist" do
        lambda { described_class.new "blob.gal" }.should raise_error(Errno::ENOENT, /File not found/)
      end

      it "fails if the file has a bad format" do
        lambda { described_class.new __FILE__ }.should raise_error(Gale::FormatError, /File not in GraphicsGale format/)
      end
    end
  end

  context "loaded an animation" do
    subject do
      described_class.new COP_RANGED_GAL
    end

    after do
      subject.close
    end


    describe "#size" do
      it "counts the number of frames" do
        subject.size.should eq 5
      end
    end

    describe "#width" do
      it "gets the width" do
        subject.width.should eq 28
      end
    end

    describe "#height" do
      it "gets the height" do
        subject.height.should eq 24
      end
    end

    describe "#background_color" do
      it "gets the color" do
        subject.background_color.should eq 0xffffff
      end
    end

    describe "#bits_per_pixel" do
      it "gets the bbp" do
        subject.bits_per_pixel.should eq 24
      end
    end

    describe "#transparency_disabled?" do
      it "is true if transparency is disabled" do
        subject.transparency_disabled?.should be_false
      end
    end

    describe "#palette_single?" do
      it "is true if there is a single palette" do
        subject.palette_single?.should be_true
      end
    end
  end
end
