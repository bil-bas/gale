require File.expand_path "../../teststrap", __FILE__

describe Gale::File do
  before :all do
    $window = Gosu::Window.new(10, 10, false)
  end

  subject do
    described_class.new File.expand_path("../data/cop_ranged.gal", File.dirname(__FILE__))
  end

  after do
    subject.close
  end


  describe "size" do
    it "counts the layers in the frame" do
      subject.map(&:size).should eq [1, 1, 2, 1, 1]
    end
  end

  describe "index" do
    it "is the ordered index of the frame within the file" do
      subject.map(&:index).should eq [0, 1, 2, 3, 4]
    end
  end

  describe "delay" do
    it "gets delay, in ms, from the frame" do
      subject.map(&:delay).should eq [500, 375, 125, 250, 250]
    end
  end

  describe "frame_transparent_color" do
    it "gets transparent_color from the frame" do
      subject.each do |frame|
        frame.transparent_color.should eq Gosu::Color.rgb(253, 77, 211)
      end
    end
  end

  describe "frame_name" do
    it "gets name of frame" do
      subject.map(&:name).should eq %w[stand aim bang recoil recover]
    end
  end

  describe "export_bitmap" do
    it "should export the composed frame as a bitmap" do
      subject.each do |frame|
        file = "test_output/frame_#{frame.index}.bmp"
        frame.export_bitmap file
        File.exists?(file).should be_true
        File.size(file).should be > 0
      end
    end
  end

  describe "to_image" do
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
