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



    def each_children(node)
      node.children.select(&.element?).reject(&.comment?).each_with_index do |child, i|
        yield child, i
      end
    end



    def link?(element)
      element[:href] =~ /^(\#|javascript|mailto|\/$)/ unless element[:href].nil?
    end



  end

end
