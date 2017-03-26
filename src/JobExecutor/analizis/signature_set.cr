module Analizis

  # set of signatures in sequence
  #
  class SignatureSet
    @mode : Symbol
    @channel : Channel(Bool)

    def initialize(@mode, @option_set : OptionSet, @channel)
      @signatures = [] of Signature
    end

    # add signature to set, and check matches with saved signatures
    def <<(signature : Signature)
      # if find_match(signature)
      #   # all right
      # elsif # @signatures.size option.invalid?
      #   irrelevant!
      # elsif # if the new signature has an acceptable difference
      #   @signatures << signature
      # end
    end

    private def irrelevant!
      @channel.send false
    end

    private def find_match(signature) : Bool
      return false if @signatures.empty?
      @signatures.each do |saved_signature|
        # difference = arrays_diff(saved_signature)
        # А вот тут нужен способ сравнить результаты сигнатур с помощью опций
        # И это ответственность не этого класса
        # difference = arr_sizes_diff(signature, saved_signature)
        # @option_set.validate(difference, diff_trigger: true)

        # return true if false
      end
      false
    end

    private def arr_sizes_diff(arr1, arr2) : Int32
      min, max = *[arr1.size, arr2.size].sort
      result = 100 - min.to_f / max.to_f * 100
      result.floor.to_i
    end

    private def arrays_diff(arr1, arr2) : Int32
      smallest, biggest = [arr1, arr2].sort_by(&.size)
      result = (biggest - smallest).size.to_f / biggest.size.to_f * 100
      result.floor.to_i
    end
  end # SignatureSet
end
