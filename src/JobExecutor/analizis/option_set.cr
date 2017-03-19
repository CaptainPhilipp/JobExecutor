# Парсит имя опции, сохраняет её значение
# validate(current_value) возвращает соответствует ли значение опции
class OptionSet
  alias SignatureValues = Int32 | Array(String)
  alias OptionsHash = Hash(String, Option)

  def initialize
    # by #diff_trigger?
    @options = {true => OptionsHash.new, false => OptionsHash.new}
  end

  def <<(option : Option)
    @options[option.diff_trigger?][option.key_name] = option
  end

  def take(key_name : String, *, diff_trigger = false) : Option?
    @options[diff_trigger][key_name]?
  end

  def take(key_name : Symbol, *, diff_trigger = false) : Option?
    take(key_name.to_s, diff_trigger)
  end

  def [](key_name : String) : Option?
    take(key_name)
  end

  def [](key_name : Symbol) : Option?
    take(key_name.to_s)
  end

  def fill_with(options_hash : Hash(String, Int32))
    options_hash.each do |key_name, value|
      self << Option.new(key_name, value)
    end
  end

  # def check(results, *, diff_trigger = false)
  #   @options[diff_trigger].each do |key_name, option|
  #     result = results[option.name]?
  #     result = result.size if result.is_a?(List) && option.size_trigger?
  #     return false if option.irrelevant?(result.not_nil!)
  #   end
  #   true
  # end


end
