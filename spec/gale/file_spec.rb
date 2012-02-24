require File.expand_path "../../teststrap", __FILE__

describe Gale::File do
  before :all do
    $window = Gosu::Window.new(10, 10, false)

    # Clean any previous test output.
    ouput_directory = File.expand_path "../../../test_output", __FILE__
    Dir["#{ouput_directory}/*.*"].each {|f| File.delete f }
    File.mkdir ouput_directory unless File.exists? ouput_directory
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

    describe "num_frames" do
      it "counts the number of frames" do
        subject.num_frames.should eq 5
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
        sheet.save "test_output/sheet_1_row.png"
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
        sheet.save "test_output/sheet_1_column.png"
      end
    end

    context "frames" do
      describe "num_layers" do
        it "counts the layers in every available frame" do
          subject.num_frames.times.map {|f| subject.num_layers f }.should eq [1, 1, 2, 1, 1]
        end
      end

      describe "frame_delay" do
        it "gets delays from each frame" do
          subject.num_frames.times.map {|f| subject.frame_delay(f) }.should eq [500, 375, 125, 250, 250]
        end
      end

      describe "frame_transparent_color" do
        it "gets transparent_color from each frame" do
          subject.num_frames.times do |f|
            subject.frame_transparent_color(f).should eq Gosu::Color.rgb(253, 77, 211)
          end
        end
      end

      describe "frame_name" do
        it "gets frame names" do
          subject.num_frames.times.map {|f| subject.frame_name(f) }.should eq %w[stand aim bang recoil recover]
        end
      end

      describe "export_bitmap" do
        it "should export each composed frame as a bitmap" do
          subject.num_frames.times do |frame|
            file = "test_output/frame_#{frame}.bmp"
            subject.export_bitmap(file, frame)
            File.exists?(file).should be_true
            File.size(file).should be > 0
          end
        end
      end

      describe "to_image" do
        it "creates a Gosu Image" do
          subject.num_frames.times do |frame|
            image = subject.to_image frame
            image.should be_a Gosu::Image
            image.width.should eq 28
            image.height.should eq 24
            image.save "test_output/frame_#{frame}.png"
          end
        end
      end

      describe "to_blob" do
        it "generates a binary blob" do
          #p subject.to_blob(0, 0)
        end

        it "can be made into a Gosu Image" do
          #gosu_image = Gosu::Image.from_blob $window, subject.to_blob(0, 0), subject.width, subject.height
          #gosu_image.width.should eq 28
          #gosu_image.height.should eq 24
        end
      end

      context "layers" do
        describe "layer_name" do
          it "gets layer names" do
            subject.num_frames.times.map do |f|
              subject.num_layers(f).times.map do |l|
                subject.layer_name(f, l)
              end
            end.should eq [%w[Layer1], %w[Layer1], %w[cop flare], %w[Layer1], %w[Layer1]]
          end
        end

        describe "layer_transparent_color" do
          it "gets transparent_color from each frame" do
            subject.num_frames.times do |frame|
              subject.num_layers(frame).times do |layer|
                subject.layer_transparent_color(frame, layer).should eq Gosu::Color.rgb(0, 0, 1)
              end
            end
          end
        end

        describe "to_image" do
          it "creates a Gosu Image" do
            subject.num_frames.times do |frame|
              subject.num_layers(frame).times do |layer|
                image = subject.to_image frame, layer
                image.should be_a Gosu::Image
                image.width.should eq 28
                image.height.should eq 24
                image.save "test_output/layer_#{frame}_#{layer}.png"
              end
            end
          end
        end

        describe "export_bitmap" do
          it "should export each layer as a bitmap" do
            subject.num_frames.times do |frame|
              subject.num_layers(frame).times do |layer|
                file = "test_output/layer_#{frame}_#{layer}.bmp"
                subject.export_bitmap(file, frame, layer)
                File.exists?(file).should be_true
                File.size(file).should be > 0
              end
            end
          end
        end

        describe "export_alpha_channel" do
          it "should export each alpha channel as a bitmap" do
            subject.num_frames.times do |frame|
              subject.num_layers(frame).times do |layer|
                file = "test_output/alpha_channel_#{frame}_#{layer}.bmp"
                subject.export_alpha_channel(file, frame, layer)
                File.exists?(file).should be_true
                File.size(file).should be > 0
              end
            end
          end
        end
      end
    end
  end
end
