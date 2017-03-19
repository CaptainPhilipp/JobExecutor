module Analizis
  class SignatureSet
    @mode : Symbol
    @channel : Channel(Bool)

    def initialize(@mode, options : OptionSet, @channel)
      @signatures = [] of Signature
    end

    def <<(signature : Signature)
      if # find compareable in @signatures
        # all right
      elsif # @signatures.size option.invalid?
        invalid!
      else
        @signatures << signature
      end
    end

    private def invalid!
      @channel.send false
    end

    private def find_match(signature)
      return false if @signatures.empty?
      @signatures.each do |saved_signature|
        # look difference
        return true if false
      end
      false
    end
  end
end
