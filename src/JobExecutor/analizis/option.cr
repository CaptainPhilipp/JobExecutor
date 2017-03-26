# Хранит данные опции для последующей проверки релевантности
struct Option
  getter full_name : String, requirement : Int32, name : String,
         compare_trigger : String

  getter? size_trigger : Bool, diff_trigger : Bool

  def initialize(@full_name, @requirement, @name, @compare_trigger,
                 @size_trigger, @diff_trigger)
  end

  alias key_name = full_name
  alias option_value = requirement
end
