module Analizis
  class Reviewer
    alias OptionValue = Int32



    def initialize(@signature_values : Signature::StampsData) end



    def validate(key, option_value) : Bool?
      option_name_arr = key.split("_")

      min_or_max = shift_min_or_max pointerof(option_name_arr)
      signature_value = get_signature_value(option_name_arr)
      compare signature_value, option_value, min_or_max
    end



    private def shift_min_or_max(option_name_arr : Array(String)*) : String?
      min_or_max = %w(min max) & option_name_arr.value
      return if min_or_max.size == 0
      raise  "Wrong option name! only 'min' or 'max'" if min_or_max.size > 1

      option_name_arr.value -= min_or_max
      min_or_max.first
    end



    # comparing of signature and option values by option name splitting
    private def compare(signature_value, option_value, min_or_max) : Bool?
      case min_or_max
      when "min" then signature_value >= option_value
      when "max" then signature_value <= option_value
      end
    end



    private def get_signature_value(cleared_key) : Int32
      signature_value = @signature_values[cleared_key.join "_"]
      size_needed = signature_value.is_a?(Array) && cleared_key.delete("size")
      size_needed ? signature_value.as(Array(String)).size : signature_value.as(Int32)
    end
  end
end
