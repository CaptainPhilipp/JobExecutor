require "./helpers/*"

module JobExecutor
  module Scan

    class Product < Scan::Job
      @@job_name = "product_scan"

      def run : Void
        Analizis::Page.new @source_uri, get_job_options
      end
    end
  end
end
