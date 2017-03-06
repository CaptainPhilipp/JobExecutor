require "./helpers/*"

module JobExecutor
  module Scan

    class ProductsList < Scan::Job
      @@job_name = "products_list"

      def run : Void
        Analizis::Page.new @source_uri, get_job_options
      end
    end
  end
end
