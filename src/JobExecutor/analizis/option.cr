# Хранит данные опции для последующей проверки релевантности
struct Option
  getter full_name : String, requirement : Int32, name : String, compare_trigger : String
  getter? size_trigger : Bool, diff_trigger : Bool

  def initialize(@full_name,        # max_childs_size
                 @requirement,      # 10      ("max_childs_size" => 10)
                 @name,             # childs  (_childs_)
                 @compare_trigger,  # >       (max_)
                 @size_trigger,     # true    (_size)
                 @diff_trigger)     # false   (_diff)
  end

  alias key_name = full_name
  alias option_value = requirement
end
