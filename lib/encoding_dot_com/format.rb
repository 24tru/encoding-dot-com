module EncodingDotCom
  # Base class for all formats sent to encoding.com
  #
  # You should create formats by calling +create+ with format attributes.
  class Format
    class << self
      # Factory method that returns an appropriate Format. The
      # +output+ attribute is required, others are optional (see the
      # encoding.com documentation for full list of attributes).
      def create(attributes)
        attributes = sanitize_attributes(attributes)
        if attributes["output"] == "thumbnail"
          ThumbnailFormat.new(attributes)
        elsif attributes["output"] == "flv" && attributes["video_codec"] == "vp6"
          FLVVP6Format.new(attributes)
        elsif attributes["output"] == "image"
          ImageFormat.new(attributes)
        elsif attributes["output"] == "muxer"
          MuxerFormat.new(attributes)
        else
          VideoFormat.new(attributes)
        end
      end

      def allowed_attributes(*attrs) #:nodoc:
        @allowed_attributes ||= []
        if attrs.empty?
          @allowed_attributes
        else
          @allowed_attributes += attrs.map {|a| a.to_s }.each { |attr| define_method(attr) { @attributes[attr] } }
        end
      end

      def boolean_attributes(*attrs) #:nodoc:
        @boolean_attributes ||= []
        if attrs.empty?
          @boolean_attributes
        else
          allowed_attributes *attrs
          @boolean_attributes += attrs.map {|a| a.to_s }
        end
      end
    end

    # Builds the XML for this format.
    #
    # +builder+:: a Nokogiri builder, declared with a block
    def build_xml(builder)
      build_node(builder, :format, @attributes)
    end

    protected

    def self.sanitize_attributes(attributes={})
      attributes.reduce({}) do |hash,(key,value)|
        value = self.sanitize_attributes(value) if value.kind_of?(Hash)
        hash.merge key.to_s => value
      end
    end

    private

    # Builds the XML for this node.
    #
    # +builder+:: a Nokogiri builder, declared with a block
    # +node+:: the current node you want to attach the data to
    # +attributes+:: attributes to be set for the node
    def build_node(builder, node, attributes)
      builder.method_missing(node) {
        attributes.each do |key, value|
          #make sure the key is allowed
          if self.class.allowed_attributes.include? key.to_s
            #if the value is a hash, recursivley call this function until the xml is properly built
            value = output_value(key, value)
            if value.kind_of?(Hash)
              build_node builder, key, value
            # if the value is an array, loop through the array and add an xml node of the same key name for each value
            elsif value.kind_of?(Array)
              value.each do |v|
                if v.kind_of?(Hash) || v.kind_of?(Array)
                  build_node builder, key, v
                else
                  builder.send("#{key}_", v) unless v.nil?
                end
              end
            else
              # adding underscore after the key to force it to be a tag instead of matching nokogiri functions
              builder.send("#{key}_", value) unless value.nil?
            end
          end
        end
      }
    end

    # Returns a value suitable for the format XML - i.e. translates
    # booleans to yes/no.
    def output_value(key, value)
      if self.class.boolean_attributes.include?(key)
        (value ? "yes" : "no")
      else
        value
      end
    end
  end
end
