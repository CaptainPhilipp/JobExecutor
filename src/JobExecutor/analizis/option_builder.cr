require "./helpers/*"

module Analizis

  # parse option full_name and save option properties
  class OptionBuilder
    COMPARING_TRIGGERS = %w(min max)
    
    class OptionError < StandardError; end
    class OptionNameError < OptionError; end

    private property splited_key : Array(String)

    def build_option(full_name : String, requirement : Int32) : Option
      splited_key     = full_name.split(" ")
      compare_trigger = exarticulate_compare_trigger
      size_trigger    = exarticulate_size_trigger
      diff_trigger    = exarticulate_difference_trigger
      name            = splited_key.join("_")
      splited_key.clear

      Option.new(full_name, requirement, name,
                 compare_trigger, size_trigger, diff_trigger)
    end

    private def exarticulate_compare_trigger : String
      trigger = (COMPARING_TRIGGERS & splited_key).first
      
      raise OptionNameError, "Compare trigger not finded" if trigger.nil?
      splited_key.delete trigger
    end

    private def exarticulate_size_trigger : Bool
      return false unless splited_key.includes? "size"
      
      splited_key.delete("size")
      true
    end

    private def exarticulate_difference_trigger : Bool
      return false unless splited_key.includes? "diff"
      
      splited_key.delete "diff"
      true
    end
  end
end
