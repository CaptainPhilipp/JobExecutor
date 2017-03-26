require "./option_builder"
require "./option_set"

module Analizis

  class OptionSetBuilder < OptionBuilder
    def build_option_set(options_hash : Hash(String, Int32))
      set = OptionSet.new
      options_hash.each { |name, value| set << build_option(name, value) }
      set
    end
  end
end
