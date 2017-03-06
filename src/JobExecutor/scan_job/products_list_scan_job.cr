require "./helpers/*"

module JobExecutor
  module Scan

    class ProductsList < Scan::Job
      JOB_NAME = "products_list"

      def run : Void
        Analizis::Page.new @source_uri, @options.value[JOB_NAME]
      end
    end


  end
end
