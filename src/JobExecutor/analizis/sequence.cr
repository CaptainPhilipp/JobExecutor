require "./helpers/*"

module Analizis

  # Looking for relevant sequence of siblings, with right data
  class Sequence
    include Helper
    getter :node, :signatures
    alias Serialized = Array(Signature::Serialized) | Nil

    MODES            = {:first, :light, :full}
    MODE_TRANSITIONS = {first: :light, light: :full}

    getter? relevant : Bool?

    def initialize(@nodeset : Array(XML::Node)*, @job_options : OptionsOfJob*)
      @mode = MODES.first.as Symbol
      @channel = Channel(Bool).new
    end

    def process
      spawn { parse }
      @relevant = @channel.receive
    end

    private def parse
      option_set = @job_options.value[@mode]
      set = SignatureSet.new(@mode, option_set, @channel)

      @nodeset.value.each_with_index do |node, index|
        node_pntr = pointerof(node)
        signature = Signature.new(node_pntr, @mode, option_set, @channel)
        signature.scan
        set << signature
      end

      # throw :validating, true unless switch_mode # true if no throws
      @channel.send true unless switch_mode # true if no throws
      parse # repeat with next mode
    end

    # для первого цикла ::new, для последющих #switch_mode_to
    private def init_signature(index, child)
      if @mode == MODES.first
        @signatures << Signature.new(child, pointerof(@mode))
      end
    end

    private def process_signature(index)
      @signatures[index].scan
    end

    def switch_mode : Bool
      return false unless MODE_TRANSITIONS[@mode]?
      @mode = MODE_TRANSITIONS[@mode]
      true
    end

    def prepare_serialize : Serialized
      return if @signatures.empty?
      @signatures.map(&.prepare_serialize).reject(&.nil?)
    end
  end
end
