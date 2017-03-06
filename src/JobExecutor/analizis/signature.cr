module Analizis

  # Build :light and :full signature for sequence finding
  class Signature
    include Helper
   alias SERIALIZED = Nil | Hash(Symbol, String | Array(String))

    def initialize(@node : XML::Node)
      @started_at = Time.now.epoch_ms.as Int64
      @mode       = :first
      @children   = all_childrens(@node).as(Array(XML::Node))
      @relevant   = true

      @name     = String.new
      @names    = Array(String).new
      @ids      = Array(String).new
      @classes  = Array(String).new
      @time     = 0
      @deep     = 0
    end



    def scan
      case @mode
      when :first then first_scan
      when :light then light_scan
      when :full  then full_scan
      end
    end


    # only @node result
    private def first_scan
      @name = @node.name.to_s
      add_results(@node, first: true)
    end



    # only @node's children result
    private def light_scan
      size = @children.size
      @deep = 1 if size > 0

      @children.each { |child| add_results(child) }
    end


    # descendent results, except @node's children
    private def full_scan
      @children.each { |child| add_results_recursive(child) }
    end


    # except node results
    private def add_results_recursive(node)
      childrens = all_childrens(node)
      return if childrens.size == 0
      @deep += 1
      childrens.each do |child|
        add_results(child)
        add_results_recursive child
      end
    end



    private def add_results(node, first = false)
      attributes = node.attributes

      @names    << node.name unless first
      @ids      += get_attributes(attributes, "id")
      @classes  += get_attributes(attributes, "class")

      now         = Time.now.epoch_ms
      @time      += now - @started_at
      @started_at = now
    end



    def relevant?(options : Page::OPTIONS)
      current_values = {names: @names, ids: @ids, classes: @classes, deep: @deep}
      reviewer = Analizis::OptionReviewer.new current_values.to_h

      return @relevant unless options && options[@mode.to_s]?
      options[@mode.to_s].each do |option, value|
        to_irrelevant unless reviewer.validate option, value
      end

      @relevant # dummy
    end



    def to_irrelevant
      @relevant = false
    end



    def switch_mode_to(mode : Symbol)
      modes = [:first, :light, :full]
      if modes.includes? mode
        @mode = mode
      else
        raise "ERROR: Wrong mode"
      end
    end



    def prepare_serialize : SERIALIZED
      return if @name.blank? && @ids.empty? && @classes.empty?
      { time:    @time.to_s,
        deep:    @deep.to_s,
        name:    @name,
        names:   @names,
        ids:     @ids,
        classes: @classes }.to_h
    end



    private def get_attributes(attributes, name) : Array(String)| Array(Nil)
      return [] of String unless attributes[name]?
      matched = /\A\s?#{name}="([a-z -0-9_A-Z]*)"\z/.match(attributes[name].to_s)
      results = (matched.try &.[1]).try &.split(" ")
      results && results.any? ? results : [] of String
    end
  end # class

end
