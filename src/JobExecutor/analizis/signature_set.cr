module Analizis
  class SignatureSet
    @mode : Symbol
    @channel : Channel(Bool)

    def initialize(@mode, @option_set : OptionSet, @channel)
      @signatures = [] of Signature
    end

    def <<(signature : Signature)
      if # find comparable in @signatures
        # all right
      elsif # @signatures.size option.invalid?
        irrelevant!
      else
        @signatures << signature
      end
    end

    private def irrelevant!
      @channel.send false
    end

    private def find_match(signature)
      return false if @signatures.empty?
      @signatures.each do |saved_signature|
        # difference = arr_sizes_diff(signature, saved_signature)
        # @option_set.validate(difference, diff_trigger: true)

        # return true if false
      end
      false
    end

    private def arr_sizes_diff(arr1, arr2)
      (arr1.size - arr2.size).abs
    end

    private def arrays_diff(arr1, arr2)
      arrays = [arr1, arr2].sort_by(&.size)
      (arrays.last - arrays.first).size
    end
  end # SignatureSet
end
