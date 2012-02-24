require File.expand_path "../../teststrap", __FILE__

describe Gale::File do
  before :all do
    $window = Gosu::Window.new(10, 10, false)
  end

  context "class" do
    describe "new" do
      it "fails if the file doesn't exist" do
        ->{ described_class.new "blob.gal" }.should raise_error(Errno::ENOENT, /File not found/)
      end

      it "fails if the file has a bad format" do
        ->{ described_class.new __FILE__ }.should raise_error(Gale::FormatError, /File not in GraphicsGale format/)
      end
    end
  end

  context "loaded an animation" do
    subject do
      described_class.new File.expand_path("../data/cop_ranged.gal", File.dirname(__FILE__))
    end

    after do
      subject.close
    end


    describe "size" do
      it "counts the number of frames" do
        subject.size.should eq 5
      end
    end

    describe "width" do
      it "gets the width" do
        subject.width.should eq 28
      end
    end

    describe "height" do
      it "gets the height" do
        subject.height.should eq 24
      end
    end

    describe "background_color" do
      it "gets the color" do
        subject.background_color.should eq Gosu::Color::WHITE
      end
    end

    describe "bits_per_pixel" do
      it "gets the bbp" do
        subject.bits_per_pixel.should eq 24
      end
    end

    describe "to_spritesheet" do
      it "creates a sprite_sheet in a single animation row" do
        sheet = subject.to_spritesheet
        sheet.should be_a Gosu::Image
        sheet.width.should eq 28 * 5
        sheet.height.should eq 24
        sheet.save "test_output/sheet_row.png"
      end

      it "creates a sprite_sheet in a grid" do
        sheet = subject.to_spritesheet :columns => 3
        sheet.should be_a Gosu::Image
        sheet.width.should eq 28 * 3
        sheet.height.should eq 24 * 2
        sheet.save "test_output/sheet_3_columns.png"
      end

      it "creates a sprite_sheet in a single column" do
        sheet = subject.to_spritesheet :columns => 1
        sheet.should be_a Gosu::Image
        sheet.width.should eq 28
        sheet.height.should eq 24 * 5
        sheet.save "test_output/sheet_column.png"
      end
    end
  end
end
