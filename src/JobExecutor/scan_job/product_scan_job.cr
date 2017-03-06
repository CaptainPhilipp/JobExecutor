require "./helpers/*"

module JobExecutor
  module Scan

    class Product < Scan::Job
      JOB_NAME = "product_scan"

      def run : Void
        Analizis::Page.new @source_uri, @options.value[JOB_NAME]
      end
    end
  end
end
