struct Results
  alias List = Array(String)
  property deep = 0, names, ids, classes
  @tuple : NamedTuple(names: List*, ids: List*, classes: List*, deep: Int32*)

  def initialize
    @names, @ids, @classes = List.new, List.new, List.new
    @tuple = {
      names:   pointerof(@names),
      ids:     pointerof(@ids),
      classes: pointerof(@classes),
      deep:    pointerof(@deep)
    }
  end

  def [](key)
    @tuple[key].value
  end

  def []?(key)
    @tuple[key]? ? self[key] : nil
  end

  def to_h
    @tuple.map { |key, value_pointer| [key, value_pointer.value] }.to_h
  end
end
