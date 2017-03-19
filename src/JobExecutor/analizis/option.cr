# Парсит имя опции, сохраняет её значение
# validate(current_value) возвращает соответствует ли значение опции
class Option
  getter name : String
  getter key_name : String
  getter option_value : Int32
  private getter  splited_key : Array(String)
  private getter? size_trigger  : Bool
  private getter! comparing_block : Proc(Int32, Bool)

  # min или max в имени опции укажут способ сравнения
  # size укажет нужно ли вычислять размер результата
  def initialize(@key_name, @option_value)
    @splited_key     = @key_name.split(" ")
    # parse
    compare_trigger  = exarticulate_compare_trigger
    @size_trigger    = exarticulate_size_trigger
    # finish
    @comparing_block = comparing_blocks[compare_trigger]
    @name          = @splited_key.join("_")
    @splited_key.clear
  end

  def validate(current_value : Int32) : Bool
    comparing_block.call(current_value)
  end

  def validate(current_values : Array(String)) : Bool
    raise "no size trigger in key_name" unless size_trigger?
    comparing_block.call(current_values.size)
  end

  def invalid?(current_values)
    !validate(current_values)
  end

  private def exarticulate_compare_trigger : String
    compare_triggers = @splited_key & comparing_blocks.keys
    trigger = compare_triggers.first
    raise "Compare trigger is not finded" if trigger.nil?
    @splited_key.delete trigger
    trigger
  end

  private def exarticulate_size_trigger : Bool
    return false unless @splited_key.includes? "size"
    @splited_key.delete "size"
    true
  end

  private def comparing_blocks
    { "min" => ->(current_value : Int32) { @option_value <= current_value },
      "max" => ->(current_value : Int32) { current_value <= @option_value } }
  end
end
