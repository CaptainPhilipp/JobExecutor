require "xml"
require "./helpers/*"


module Analizis
  class Page
    include Helper

    def initialize(@doc : XML::Node, @job_options : OptionsOfJob*)
      @sequences = [] of Sequence
      traverse_tree
    end

    private def traverse_tree(node = @doc)
      return if node.nil?
      childrens = all_childrens_of(node)
      sequence = Sequence.new(pointerof(childrens), @job_options)
      sequence.process
      if sequence.relevant?
        @sequences << sequence
        # TODO
      else
        childrens.each_with_index { |child| traverse_tree(child) }
      end
    end

    alias Serialized  = Array(Sequence::Serialized)

    def prepare_serialize : Serialized
      @sequences.map(&.prepare_serialize).reject(&.nil?)
    end
  end # class
end
