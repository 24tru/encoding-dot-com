require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Encoding.com video format" do
  describe "#build_xml" do
    it "should create a logo node for logo attributes" do
      format = EncodingDotCom::VideoFormat.new(output: "flv", logo: {logo_x: 30, logo_source: "http://www.example.com"})
      Nokogiri::XML::Builder.new do |b|
        format.build_xml(b)
      end.to_xml
      .should have_xpath("/format/logo/logo_x[text()='30']")
    end

    it "should not allow illegal logo attributes" do
      lambda { EncodingDotCom::VideoFormat.new(output: "flv", logo: {logo_x: 30}) }.should raise_error(EncodingDotCom::IllegalFormatAttribute)
    end

    it "should allow creation of logo attributes" do
      lambda { EncodingDotCom::VideoFormat.new(output: "flv", logo: {logo_x: 30, logo_source: "http://www.example.com"}) }.should_not raise_error
    end

    it "should create a closed_caption node for caption attributes" do
      format = EncodingDotCom::VideoFormat.new(output: "flv", closed_captions: {time_offset: 30})
      Nokogiri::XML::Builder.new do |b|
        format.build_xml(b)
      end.to_xml
      .should have_xpath("/format/closed_captions/time_offset[text()='30']")
    end

    it "should create a metadata node for metadata attributes" do
      format = EncodingDotCom::VideoFormat.new(output: "flv", metadata: {copyright: "Foo"})
      Nokogiri::XML::Builder.new do |b|
        format.build_xml(b)
      end.to_xml
      .should have_xpath("/format/metadata/copyright[text()='Foo']")
    end

    it "should create a overlay node for overlay attributes" do
      format = EncodingDotCom::VideoFormat.new(output: "flv", overlay: {overlay_x: 30, overlay_source: "http://www.example.com"})
      Nokogiri::XML::Builder.new do |b|
        format.build_xml(b)
      end.to_xml
      .should have_xpath("/format/overlay/overlay_x[text()='30']")
    end

    it "should not allow illegal overlay attributes" do
      lambda { EncodingDotCom::VideoFormat.new(output: "flv", overlay: {overlay_x: 30}) }.should raise_error(EncodingDotCom::IllegalFormatAttribute)
    end

    it "should allow creation of overlay attributes" do
      lambda { EncodingDotCom::VideoFormat.new(output: "flv", overlay: {overlay_x: 30, overlay_source: "http://www.example.com"}) }.should_not raise_error
    end

    it "should create a text_overlay node for text overlay attributes" do
      format = EncodingDotCom::VideoFormat.new(output: "flv", text_overlay: {overlay_x: 30, font_source: "http://www.example.com", text: 'foo'})
      Nokogiri::XML::Builder.new do |b|
        format.build_xml(b)
      end.to_xml
      .should have_xpath("/format/text_overlay/overlay_x[text()='30']")
    end

    it "should create a text node for text overlay attributes" do
      format = EncodingDotCom::VideoFormat.new(output: "flv", text_overlay: {overlay_x: 30, font_source: "http://www.example.com", text: 'foo'})
      Nokogiri::XML::Builder.new do |b|
        format.build_xml(b)
      end.to_xml
      .should have_xpath("/format/text_overlay/text[text()='foo']")
    end

    it "should not allow illegal text overlay attributes" do
      lambda { EncodingDotCom::VideoFormat.new(output: "flv", text_overlay: {overlay_x: 30, font_source: "http://www.example.com"}) }.should raise_error(EncodingDotCom::IllegalFormatAttribute)
    end

    it "should not allow illegal text overlay attributes" do
      lambda { EncodingDotCom::VideoFormat.new(output: "flv", text_overlay: {overlay_x: 30, text: 'foo'}) }.should raise_error(EncodingDotCom::IllegalFormatAttribute)
    end

    it "should allow creation of text overlay attributes" do
      lambda { EncodingDotCom::VideoFormat.new(output: "flv", text_overlay: {overlay_x: 30, font_source: "http://www.example.com", text: 'foo'}) }.should_not raise_error
    end

    it 'creates an audio_stream node for audio stream attributes' do
      format =
        EncodingDotCom::VideoFormat.new(
          output: "flv",
          audio_stream: { use_stream_id: 1 }
        )

      xml = Nokogiri::XML::Builder.new { |b| format.build_xml(b) }.to_xml

      xml.should have_xpath("/format/audio_stream/use_stream_id[text()='1']")
    end

    it 'creates a channel node for stereo split' do
      format =
        EncodingDotCom::VideoFormat.new(
          output: "mp4",
          audio_stream: { channel: { id: 'FC', in: { id: '1:1' } }}
        )

      xml = Nokogiri::XML::Builder.new { |b| format.build_xml(b) }.to_xml

      xml.should have_xpath("/format/audio_stream/channel/id[text()='FC']")
      xml.should have_xpath("/format/audio_stream/channel/in/id[text()='1:1']")
    end
  end
end
