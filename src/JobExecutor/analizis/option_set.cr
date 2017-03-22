# validate(current_value) возвращает соответствует ли значение опции
# собирает опции в Сет Опций (минимальная группа опций)
# Проверяет результаты сигнатур на соответствие требованиям в опциях
# То есть отправляет нужные результаты в нужные инстансы Option
# и возвращает результат работы
#
class OptionSet
  alias SignatureValues = Int32 | Array(String)
  alias OptionsHash = Hash(String, Option)

  def initialize
    @options = NamedTuple{diff: OptionsHash.new, normal: OptionsHash.new}
  end

  # add option to set
  def <<(option : Option)
    diff_key = get_diff_trigger_key(option.diff_trigger)
    @options[diff_key][option.key_name] = option
  end

  # # take option from set
  # def take(key_name : String, *, diff_trigger = false) : Option?
  #   diff_key = get_diff_trigger_key(diff_trigger)
  #   @options[diff_key][key_name]?
  # end
  #
  # def take(key_name : Symbol, *, diff_trigger = false) : Option?
  #   take(key_name.to_s, diff_trigger)
  # end
  #
  # alias [] = take

  # fill set with hash
  def fill_with_options_hash(options_hash : Hash(String, Int32))
    options_hash.each do |key_name, value|
      self << Option.new(key_name, value)
    end
  end

  alias fill_with = fill_with_options_hash

  # Check results of signature with requirements
  # For Diff and Normal results
  # For check differences, it is need for set diff_trigger arg to true
  # 
  # TODO: сейчас возможно проверять хэш одиночных результатов сигнатуры
  # Но нужно сделать возможность проверять специальный diff результат,
  # вычисляемый непосредственно для проверки, при сравнении результатов двух сигнатур
  # при этом сей класс не должен ничего вычислять. вообще. только сравнивать.
  def check(results, *, diff_trigger = false)
    diff_key = get_diff_trigger_key(diff_trigger)
    @options[diff_key].each do |key_name, option|
      next unless result = results[option.name]?
      # вот тут нужно как-то каждую опцию правильно проверить, какой бы она ни была
      # result = result.size if result.is_a?(List) && option.size_trigger?
      # return false if option.irrelevant?(result.not_nil!)
    end
    true
  end

  # difference key by bool trigger
  private def get_diff_trigger_key(diff_trigger)
    diff_trigger ? :diff : :normal
  end
end
