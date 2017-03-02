require "./helpers/*"

module Analizis

  # Looking for relevant sequence of siblings, with right data
  class Sequence
    include Helper
    getter :node

    @relevant : Bool?

    def initialize(@node : XML::Node)
      @signatures = [] of Signature

      process_sequence :light
    end



    def process_sequence(option)
      each_children(@node) do |child, index|

        init_signature    index, option, child
        process_signature index, option
        check_signature   index

        return unless relevant?
      end
      process_sequence :full if option == :light && relevant?
    end



    def init_signature(index, option, child)
      case option
      when :light then @signatures << Signature.new(child)
      when :full  then @signatures[index].switch_option_to_full
      end
    end



    def process_signature(index, option)
      @signatures[index].scan(option) # :light or :full
    end



    def check_signature(index)
      #
      # TODO
      #
      @relevant = false
    end



    def relevant?
      @relevant
    end

  end

end
