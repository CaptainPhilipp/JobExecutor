require "./helpers/*"

module JobExecutor
  module Scan

    class ProductsList < Scan::Job

      def run : Void
        Analizis::Page.new @source_uri
      end
    end


  end
end
