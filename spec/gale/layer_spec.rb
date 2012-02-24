require File.expand_path "../../teststrap", __FILE__

describe Gale::Layer do
  before :all do
    $window = Gosu::Window.new(10, 10, false)
  end

  subject do
    Gale::File.new COP_RANGED
  end

  after do
    subject.close
  end


  describe "name" do
    it "gets name" do
      subject.map {|f| f.map(&:name) }.should eq [%w[Layer1], %w[Layer1], %w[cop flare], %w[Layer1], %w[Layer1]]
    end
  end

  describe "transparent_color" do
    it "gets transparent color" do
      c = 0x000001
      subject.map {|f| f.map(&:transparent_color) }.should eq [[c], [c], [c, c], [c], [c]]
    end
  end

  describe "export_bitmap" do
    it "should export the layer as a bitmap" do
      subject.each_frame do |frame|
        frame.each_layer do |layer|
          file = "test_output/layer_#{frame.index}_#{layer.index}.bmp"
          layer.export_bitmap file
          File.exists?(file).should be_true
          File.size(file).should be > 0
        end
      end
    end
  end

  describe "export_alpha_channel" do
    it "should export the alpha channel as a bitmap" do
      subject.each_frame do |frame|
        frame.each_layer do |layer|
          file = "test_output/alpha_channel_#{frame.index}_#{layer.index}.bmp"
          layer.export_alpha_channel file
          File.exists?(file).should be_true
          File.size(file).should be > 0
        end
      end
    end
  end
end
