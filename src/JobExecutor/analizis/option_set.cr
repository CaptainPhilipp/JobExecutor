# Парсит имя опции, сохраняет её значение
# validate(current_value) возвращает соответствует ли значение опции
class OptionSet
  alias SignatureValues = Int32 | Array(String)
  alias OptionsHash = Hash(String, Option)

  def initialize
    @options = OptionsHash.new
  end

  def <<(option : Option)
    @options[option.key_name] = option
  end

  def [](key_name : String) : Option?
    @options[key_name]?
  end

  def [](key_name : Symbol) : Option?
    [key_name.to_s]
  end

  def each_option
    @options.each do |key_name, option|
      yield option, option.name, key_name
    end
  end

  def fill_with(options_hash : Hash(String, Int32))
    options_hash.each do |key_name, value|
      self << Option.new(key_name, value)
    end
  end

  def validate(signature_results)
    each_option do |option, name, key_name|
      results = signature_results[name]?
      valid = results ? option.validate(results.not_nil!) : nil
      return false if valid == false # not nil
    end
    true
  end
end
