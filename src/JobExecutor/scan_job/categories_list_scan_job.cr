require "./helpers/*"

module JobExecutor
  module Scan

    class CategoriesList < Scan::Job
      @@job_name = "categories_list"

      def run : Void
        @page = Analizis::Page.new @source_uri, get_job_options
        @page.as(Analizis::Page).read
      end
    end
  end
end
