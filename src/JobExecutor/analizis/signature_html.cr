module Analizis

  # Build :light and :full signature for sequence finding
  class Signature::HTML
    setter :name, :class
    @name  : String? | XML::Node
    @class : Array(String)? | XML::Attributes | XML::Node | String
    #
    # TODO
    #
  end # class

end
