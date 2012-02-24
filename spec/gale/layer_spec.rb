require File.expand_path "../../teststrap", __FILE__

describe Gale::File do
  before :all do
    $window = Gosu::Window.new(10, 10, false)
  end

  subject do
    described_class.new COP_RANGED
  end

  after do
    subject.close
  end


  describe "name" do
    it "gets name of layer" do
      subject.map {|f| f.map(&:name) }.should eq [%w[Layer1], %w[Layer1], %w[cop flare], %w[Layer1], %w[Layer1]]
    end
  end

  describe "transparent_color" do
    it "gets transparent_color of the layer" do
      c = Gosu::Color.rgb(0, 0, 1)
      subject.map {|f| f.map(&:transparent_color) }.should eq [[c], [c], [c, c], [c], [c]]
    end
  end

  describe "to_image" do
    it "creates a Gosu Image from the layer" do
      subject.each do |frame|
        frame.each do |layer|
          image = layer.to_image
          image.should be_a Gosu::Image
          image.width.should eq 28
          image.height.should eq 24
          image.save "test_output/layer_#{frame.index}_#{layer.index}.png"
        end
      end
    end
  end

  describe "export_bitmap" do
    it "should export the layer as a bitmap" do
      subject.each do |frame|
        frame.each do |layer|
          file = "test_output/layer_#{frame.index}_#{layer.index}.bmp"
          layer.export_bitmap file
          File.exists?(file).should be_true
          File.size(file).should be > 0
        end
      end
    end
  end

  describe "export_alpha_channel" do
    it "should export each alpha channel as a bitmap" do
      subject.each do |frame|
        frame.each do |layer|
          file = "test_output/alpha_channel_#{frame.index}_#{layer.index}.bmp"
          layer.export_alpha_channel file
          File.exists?(file).should be_true
          File.size(file).should be > 0
        end
      end
    end
  end
end
