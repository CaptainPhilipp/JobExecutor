require "./helpers/*"

module Analizis

  # Looking for relevant sequence of siblings, with right data
  class Sequence
    include Helper
    getter :node, :signatures
    @@modes            = {:first, :light, :full}
    @@mode_transitions = {first: :light, light: :full}
    @mode : Symbol
    @options : Pointer(Hash(String, Hash(String, Int32)))



    def initialize(@nodeset : Array(XML::Node), @options)
      @signatures = [] of Signature
      @relevant   = true
      @mode       = @@modes.first

      process_sequence
    end



    private def process_sequence
      @nodeset.each_with_index do |child, index|

        init_signature    index, child
        process_signature index
        check_signature   index
        return unless relevant?

        check_sequence    index
        return unless relevant?
      end

      return unless switch_mode
      process_sequence
    end



    private def init_signature(index, child)
      if @mode == @@modes.first
        @signatures << Signature.new(child)
      elsif @@modes.includes? @mode
        @signatures[index].switch_mode_to @mode
      end
    end



    private def process_signature(index)
      @signatures[index].scan
    end



    private def check_signature(index)
      to_irrelevant unless @signatures[index].relevant? @options.value
    end



    private def check_sequence(index)
      # @signatures[index]
      #
      # TODO compare signatures, stamps etc
      #
      to_irrelevant # dummy
    end



    def switch_mode : Symbol | Nil
      @mode = @@mode_transitions[@mode] if @@mode_transitions[@mode]?
    end



    def relevant? : Bool
      @relevant
    end



    def to_irrelevant
      @relevant = false
    end



    def prepare_serialize : Array(Hash(Symbol, String | Array(String))?)?
      return if @signatures.empty?
      @signatures.map(&.prepare_serialize).reject(&.nil?)
    end
  end
end
