require "./helpers/*"

module Analizis

  # Looking for relevant sequence of siblings, with right data
  class Sequence
    include Helper

    getter :node, :signatures

    alias SERIALIZED = Nil | Array(Signature::SERIALIZED)

    MODES            = {:first, :light, :full}
    MODE_TRANSITIONS = {first: :light, light: :full}
    # MODE_TRANSITIONS = {MODES[0] => MODES[1], MODES[1] => MODES[2]}

    @options : Pointer(Page::OPTIONS)

    def initialize(@nodeset : Array(XML::Node), @options)
      @signatures = [] of Signature
      @relevant   = true
      @mode       = MODES.first.as Symbol

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
      if @mode == MODES.first
        @signatures << Signature.new(child)
      elsif MODES.includes? @mode
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
      @mode = MODE_TRANSITIONS[@mode] if MODE_TRANSITIONS[@mode]?
    end



    def relevant? : Bool
      @relevant
    end



    def to_irrelevant
      @relevant = false
    end



    def prepare_serialize : SERIALIZED
      return if @signatures.empty?
      @signatures.map(&.prepare_serialize).reject(&.nil?)
    end
  end
end
