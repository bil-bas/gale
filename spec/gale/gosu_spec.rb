require File.expand_path "../../teststrap", __FILE__

describe "Gosu extension" do
  before :all do
    $window = Gosu::Window.new(10, 10, false)
  end

  subject do
    Gale::File.new COP_RANGED_GAL
  end

  after do
    subject.close
  end

  describe Gosu::Color do
    describe ".from_gale" do
      it "should use the values from an integer to construct a Color" do
        color = Gosu::Color.from_gale 0x112233
        color.red.should eq 0x11
        color.green.should eq 0x22
        color.blue.should eq 0x33
        color.alpha.should eq 0xff
      end
    end
  end

  describe Gale::File do
    describe "#to_spritesheet" do
      it "creates a sprite-sheet with a single row" do
        sheet = subject.to_spritesheet
        sheet.should be_a Gosu::Image
        sheet.width.should eq 28 * 5
        sheet.height.should eq 24
        sheet.save "test_output/sheet_row.png"

        expected = Gosu::Image.new $window, COP_RANGED_PNG
        result = Gosu::Image.new $window, "test_output/sheet_row.png"
        result.each do |c, x, y|
          c.should eq expected[x, y]
        end
      end

      it "creates a sprite-sheet in a grid" do
        sheet = subject.to_spritesheet :columns => 3
        sheet.should be_a Gosu::Image
        sheet.width.should eq 28 * 3
        sheet.height.should eq 24 * 2
        sheet.save "test_output/sheet_3_columns.png"
      end

      it "creates a sprite-sheet with a single column" do
        sheet = subject.to_spritesheet :columns => 1
        sheet.should be_a Gosu::Image
        sheet.width.should eq 28
        sheet.height.should eq 24 * 5
        sheet.save "test_output/sheet_column.png"
      end
    end
  end

  describe Gale::Frame do
    describe "#to_image" do
      it "creates a Gosu Image from the frame" do
        subject.each do |frame|
          image = frame.to_image
          image.should be_a Gosu::Image
          image.width.should eq 28
          image.height.should eq 24
          image.save "test_output/frame_#{frame.index}.png"
        end
      end
    end
  end

  describe Gale::Layer do
    describe "#to_image" do
      it "creates a Gosu Image from the layer" do
        subject.each_frame do |frame|
          frame.each_layer do |layer|
            image = layer.to_image
            image.should be_a Gosu::Image
            image.width.should eq 28
            image.height.should eq 24
            image.save "test_output/layer_#{frame.index}_#{layer.index}.png"
          end
        end
      end
    end
  end
end