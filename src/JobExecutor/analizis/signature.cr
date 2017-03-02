module Analizis

  # Build :light and :full signature for sequence finding
  class Signature
    def initialize(@node : XML::Node)
      @option = :light
      @html = Signature::HTML.new
      @data = Signature::Data.new
    end

    def scan(option : Symbol)
      case @option
      when :light then scan_self
      when :full  then scan_descendents
      end
    end

    def scan_self
      #
      # TODO скан xml атрибутов
      #
      attributes = @node.attributes
      # puts "\n #{attributes}"
      # puts @html.name  = attributes["name"] if attributes["name"]?
      # puts @html.class = attributes["id"] if attributes["id"]?
      puts @html.class = attributes["class"].to_s if attributes["class"]?
    end

    def scan_descendents
      #
      # TODO скан xml атрибутов, картинок, ссылок
      #
    end

    def switch_option_to_full
      @option = :full
    end

  end # class

end
