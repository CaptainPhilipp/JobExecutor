module Analizis

  # Signature of XML Node and his descendents
  class Signature
    include Helper
    getter mode, results

    @node : XML::Node*
    @mode : Symbol
    @option_set : OptionSet
    @channel : Channel(Bool)

    def initialize(@node, @mode, @option_set, @channel)
      @started_at = Time.now.epoch_ms.as Int64
      @childrens  = all_childrens_of(@node.value).as(Array(XML::Node))
      @results    = Results.new
    end

    # only runs once!
    def scan
      case @mode
      when :first then node_scan
      when :light then children_scan
      when :full  then descendent_scan
      end
    end

    private def node_scan
      save_results(@node.value)
    end

    # scan childrens of node
    private def children_scan
      size = @childrens.size
      @results.deep = 1 if size > 0
      @childrens.each { |child| save_results(child) }
    end

    # scan descendents of node
    private def descendent_scan
      @childrens.each { |child| save_results_recursive(child) }
    end

    # save results except current node`s results
    private def save_results_recursive(node)
      childrens = all_childrens_of(node)
      return if childrens.size == 0
      @results.deep += 1
      childrens.each do |child|
        save_results(child)
        check!
        save_results_recursive child
      end
    end

    # save results for one node
    private def save_results(node)
      attributes = node.attributes
      @results.deep    += 1
      @results.names   << node.name
      @results.ids     += extract_attribute(attributes, "id")
      @results.classes += extract_attribute(attributes, "class")

      check!
    end

    # check values in current signature instance
    def check!
      irrelevant! unless @option_set.check(@results)
    end

    def irrelevant!
      @channel.send false
    end

    alias SerialValue = Int32 | Array(String)
    alias Serialized  = Hash(Symbol, SerialValue) | Nil

    def prepare_serialize : Serialized
      @results.to_h
    end

    private def extract_attribute(attributes, name) : Array(String)| Array(Nil)
      return [] of String unless attributes[name]?
      attributes[name].to_s =~ /\A\s?#{name}="([a-z\s-0-9_]*)"\z/i

      results = $1.split(" ")
      results && results.any? ? results : [] of String
    end
  end # class

end
