module Analizis
  class OptionReviewer
    def initialize(current_values : Hash(Symbol, Int32 | Array(String)))
      @current_values = Hash(String, Int32 | Array(String)).new
      current_values.each { |sym, value| @current_values[sym.to_s] = value }
    end



    def validate(key, option_value) : Bool?
      splited = key.split("_")

      compare(splited, option_value) do |splited|
        current_value(splited)
      end
    end



    def compare(splited, option_value, &block) : Bool?
      trigger = (splited & %w(min max))
      return if trigger.size == 0
      raise "Wrong option keyname: 'min' and 'max' both" if trigger.size > 1
      current_value = yield(splited - trigger)
      case trigger.first
      when "min" then current_value >= option_value
      when "max" then current_value <= option_value
      end
    end



    def current_value(key) : Int32
      size_trigger = key.delete "size"
      current      = @current_values[key.join "_"]
      (size_trigger && current.is_a?(Array) ? current.size : current).as(Int32)
    end
  end
end
