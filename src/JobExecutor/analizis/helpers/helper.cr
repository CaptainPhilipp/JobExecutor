module Analizis
  module Helper
    # for optimize when some elements wil be rejected before full fin
    # def each_children(node)
    #   child, index = node.first_element_child, 0
    #   while child
    #     next if !child.element? || child.comment?
    #
    #     yield child, index
    #
    #     child = child.next_sibling
    #     index += 1
    #   end
    # end



    def all_childrens_of(node) : Array(XML::Node)
      node.children.select { |child| child.element? && !child.comment? }
    end



    def link?(element) : Bool
      element[:href] =~ /^(\#|javascript|mailto|\/$)/ unless element[:href].nil?
    end
  end # module
end
