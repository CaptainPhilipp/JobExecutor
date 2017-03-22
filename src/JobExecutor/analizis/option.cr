# Парсит имя опции, сохраняет её значение, способ проверки, и ключевую инфу
# Основной функционал - check и его антоним irrelevant?
# Эти методы принимают значение (цифру) и возвращают Bool
# (релевантно ли это значение)
class Option
  alias List = Array(String)

  getter name : String
  getter key_name : String
  getter option_value : Int32
  getter? size_trigger : Bool
  getter? diff_trigger  : Bool
  private getter  splited_key : List
  private getter! comparing_block : Proc(Int32, Bool)

  # min или max в имени опции укажут способ сравнения
  # size укажет нужно ли вычислять размер результата
  def initialize(@key_name, @option_value)
    @splited_key    = @key_name.split(" ")
    # parse
    compare_trigger = exarticulate_compare_trigger
    @size_trigger   = exarticulate_size_trigger
    @diff_trigger   = exarticulate_difference_trigger
    # finish
    @comparing_block = comparing_blocks[compare_trigger]
    @name = @splited_key.join("_")
    @splited_key.clear
  end

  def check(current_value : Int32) : Bool
    comparing_block.call(current_value)
  end

  def irrelevant?(current_values)
    !check(current_values)
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

  private def exarticulate_difference_trigger : Bool
    return false unless @splited_key.includes? "diff"
    @splited_key.delete "diff"
    true
  end

  def comparing_blocks
    { "min" => ->(current : Int32) { @option_value <= current },
      "max" => ->(current : Int32) { current <= @option_value } }
  end
end
